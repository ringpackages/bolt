---
title: "Benchmarks"
weight: 0
summary: "Performance comparison with other frameworks"
---

Hello-world endpoint tested with `wrk -t8 -c100 -d10s` (5s warmup) on a Ryzen 9 9950x VM (12 vCPUs).

<div class="benchmark-table-wrapper">
<table class="benchmark-table">
  <colgroup>
    <col><col><col><col><col><col>
  </colgroup>
  <thead>
    <tr>
      <th>Framework</th>
      <th>Language</th>
      <th class="num">Requests/sec</th>
      <th class="num">Avg Latency</th>
      <th class="num">vs Bolt</th>
      <th class="bar-col">Throughput</th>
    </tr>
  </thead>
  <tbody>
    <tr class="bm-faster">
      <td><strong>Actix-web</strong></td>
      <td>Rust</td>
      <td class="num">874,706</td>
      <td class="num">618.66us</td>
      <td class="num"><span class="badge badge-faster">2.1x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:100%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>Fiber</strong></td>
      <td>Go</td>
      <td class="num">606,122</td>
      <td class="num">292.52us</td>
      <td class="num"><span class="badge badge-faster">1.5x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:69%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>ASP.NET</strong></td>
      <td>.NET</td>
      <td class="num">501,285</td>
      <td class="num">273.33us</td>
      <td class="num"><span class="badge badge-faster">1.2x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:57%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>Java Virtual Threads</strong></td>
      <td>Java</td>
      <td class="num">490,197</td>
      <td class="num">221.41us</td>
      <td class="num"><span class="badge badge-faster">1.2x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:56%"></div></td>
    </tr>
    <tr class="bm-bolt">
      <td><strong>⚡ Bolt</strong></td>
      <td><strong>Ring/Rust</strong></td>
      <td class="num"><strong>415,084</strong></td>
      <td class="num"><strong>263.88us</strong></td>
      <td class="num"><span class="badge badge-bolt">—</span></td>
      <td class="bar-col"><div class="bar bar-bolt" style="width:47%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Gin</td>
      <td>Go</td>
      <td class="num">360,205</td>
      <td class="num">418.28us</td>
      <td class="num"><span class="badge badge-slower">1.2x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:41%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Bun</td>
      <td>JS</td>
      <td class="num">274,226</td>
      <td class="num">364.71us</td>
      <td class="num"><span class="badge badge-slower">1.5x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:31%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Elysia</td>
      <td>Bun</td>
      <td class="num">267,333</td>
      <td class="num">377.12us</td>
      <td class="num"><span class="badge badge-slower">1.6x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:31%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>NestJS+Fastify/Node</td>
      <td>JS</td>
      <td class="num">78,925</td>
      <td class="num">1.32ms</td>
      <td class="num"><span class="badge badge-slower">5.3x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:9%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Express/Bun</td>
      <td>JS</td>
      <td class="num">70,071</td>
      <td class="num">1.42ms</td>
      <td class="num"><span class="badge badge-slower">5.9x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:8%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Express/Node</td>
      <td>JS</td>
      <td class="num">67,191</td>
      <td class="num">1.55ms</td>
      <td class="num"><span class="badge badge-slower">6.2x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:8%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>FastAPI</td>
      <td>Python</td>
      <td class="num">2,282</td>
      <td class="num">43.64ms</td>
      <td class="num"><span class="badge badge-slower">182x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:0.3%"></div></td>
    </tr>
  </tbody>
</table>
</div>
