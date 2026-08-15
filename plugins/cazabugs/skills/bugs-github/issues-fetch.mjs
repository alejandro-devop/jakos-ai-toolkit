#!/usr/bin/env node
// Second half of issues-fetch.sh — runs from the project root (the .sh cd's
// there before calling). Filters out the issues that already have a dossier,
// prints the rest fenced with a per-run random seal, and downloads their
// screenshots to docs/bugs/attachments/issue-NNN/.
//
// The seal is the whole defense against prompt injection from issue text: the
// fences are named BODY-<seal> / COMMENTS-<seal> and the seal changes every
// run, so nothing written inside an issue can close a fence and pass itself
// off as an instruction. Whoever consumes this output must keep the fences
// intact.
//
// argv: <issues.json> <registered-csv> <limit> <screenshots-per-issue> <only>
// env:  GH_TOKEN_PROBE — token for downloading private-repo image assets.

import { readFileSync, mkdirSync, writeFileSync } from "node:fs";
import { randomBytes } from "node:crypto";
import path from "node:path";

const [jsonPath, registeredCsv = "", limitArg = "5", capArg = "2", only = ""] =
  process.argv.slice(2);

const issues = JSON.parse(readFileSync(jsonPath, "utf8"));
const registered = new Set(
  registeredCsv.split(",").filter(Boolean).map(Number),
);
const limit = Number(limitArg) || 5;
const cap = Number(capArg) || 2;
const token = process.env.GH_TOKEN_PROBE || "";

let batch, leftOut = 0;
if (only) {
  batch = issues.filter((i) => i.number === Number(only));
  if (batch.length === 0) {
    console.log(
      `Issue #${only} is not among the open issues labeled 'bug'. Nothing to do.`,
    );
    process.exit(0);
  }
} else {
  const pending = issues.filter((i) => !registered.has(i.number));
  leftOut = Math.max(0, pending.length - limit);
  batch = pending.slice(0, limit);
}

const today = new Date().toISOString().slice(0, 10);
const seal = randomBytes(4).toString("hex");

console.log(`TODAY: ${today}   (the bug-reporter has no Bash and cannot find this out alone)`);
console.log(`SEAL: ${seal}   (fences below are BODY-${seal} / COMMENTS-${seal}; keep them intact)`);
console.log(`PENDING IN THIS BATCH: ${batch.length}${leftOut ? `   (${leftOut} more left out by the batch cap; re-run or raise --limit)` : ""}`);

if (batch.length === 0) {
  console.log("Nothing pending: every open issue labeled 'bug' already has a dossier.");
  process.exit(0);
}

// Markdown images and raw <img> tags, which is how screenshots appear in
// issues whether dragged in or pasted as HTML.
const IMG = /!\[[^\]]*\]\((https?:\/\/[^\s)]+)\)|<img[^>]+src="(https?:\/\/[^"]+)"/g;

const extFrom = (url, contentType) => {
  const byType = {
    "image/png": ".png", "image/jpeg": ".jpg", "image/gif": ".gif",
    "image/webp": ".webp", "image/svg+xml": ".svg",
  }[contentType?.split(";")[0]];
  if (byType) return byType;
  const fromUrl = path.extname(new URL(url).pathname);
  return fromUrl && fromUrl.length <= 5 ? fromUrl : ".png";
};

for (const issue of batch) {
  console.log(`\n=== ISSUE #${issue.number} ===`);
  console.log(`title: ${issue.title}`);
  console.log(`author: ${issue.author?.login ?? "unknown"}`);
  console.log(`created: ${issue.createdAt}`);
  console.log(`url: ${issue.url}`);
  if (registered.has(issue.number)) {
    console.log("NOTE: already registered (reprocessing via --issue; a duplicate dossier is possible).");
  }

  console.log(`BODY-${seal}`);
  console.log(issue.body?.trim() || "(no body)");
  console.log(`END-BODY-${seal}`);

  console.log(`COMMENTS-${seal}`);
  if (issue.comments?.length) {
    for (const c of issue.comments) {
      console.log(`--- ${c.author?.login ?? "unknown"} (${c.createdAt}):`);
      console.log(c.body?.trim() || "(empty)");
    }
  } else {
    console.log("(no comments)");
  }
  console.log(`END-COMMENTS-${seal}`);

  // Screenshots: first `cap` image URLs across body + comments, downloaded so
  // the bug-reporter gets local paths and never touches the network itself.
  const text = [issue.body ?? "", ...(issue.comments ?? []).map((c) => c.body ?? "")].join("\n");
  const urls = [...text.matchAll(IMG)].map((m) => m[1] ?? m[2]).slice(0, cap);
  const skipped = [...text.matchAll(IMG)].length - urls.length;

  for (const [k, url] of urls.entries()) {
    const dir = `docs/bugs/attachments/issue-${issue.number}`;
    try {
      const res = await fetch(url, {
        headers: token ? { Authorization: `token ${token}` } : {},
        redirect: "follow",
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const file = `screenshot-${k + 1}${extFrom(url, res.headers.get("content-type"))}`;
      mkdirSync(dir, { recursive: true });
      writeFileSync(path.join(dir, file), Buffer.from(await res.arrayBuffer()));
      console.log(`screenshot: ${dir}/${file}`);
    } catch (err) {
      // Not a reason to stop: the bug gets registered without it and the gap
      // is noted in the dossier.
      console.log(`screenshot FAILED (${err.message}): ${url}`);
    }
  }
  if (skipped > 0) console.log(`screenshots left out by the per-issue cap: ${skipped}`);
}
