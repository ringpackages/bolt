---
title: "Benchmarks"
weight: 0
summary: "Performance comparison with other frameworks"
---

Hello-world endpoint tested with `wrk -t16 -c1000 -d30s` on a dedicated server with AMD Ryzen 9 9950X (32 CPUs, 128 GiB RAM), Ubuntu 26.04.

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
      <td class="num">4,209,699</td>
      <td class="num">282.71us</td>
      <td class="num"><span class="badge badge-faster">7.2x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:100%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>Java Virtual Threads</strong></td>
      <td>Java</td>
      <td class="num">3,874,620</td>
      <td class="num">262.46us</td>
      <td class="num"><span class="badge badge-faster">6.6x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:92%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>ASP.NET</strong></td>
      <td>.NET</td>
      <td class="num">1,859,957</td>
      <td class="num">617.27us</td>
      <td class="num"><span class="badge badge-faster">3.2x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:44%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>Gin</strong></td>
      <td>Go</td>
      <td class="num">1,126,549</td>
      <td class="num">1.08ms</td>
      <td class="num"><span class="badge badge-faster">1.9x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:27%"></div></td>
    </tr>
    <tr class="bm-faster">
      <td><strong>Fiber</strong></td>
      <td>Go</td>
      <td class="num">1,034,599</td>
      <td class="num">1.29ms</td>
      <td class="num"><span class="badge badge-faster">1.8x faster</span></td>
      <td class="bar-col"><div class="bar" style="width:25%"></div></td>
    </tr>
    <tr class="bm-bolt">
      <td><strong>⚡ Bolt</strong></td>
      <td><strong>Ring/Rust</strong></td>
      <td class="num"><strong>584,918</strong></td>
      <td class="num"><strong>1.62ms</strong></td>
      <td class="num"><span class="badge badge-bolt">—</span></td>
      <td class="bar-col"><div class="bar bar-bolt" style="width:14%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Bun</td>
      <td>JS</td>
      <td class="num">430,449</td>
      <td class="num">2.41ms</td>
      <td class="num"><span class="badge badge-slower">1.4x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:10%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Elysia</td>
      <td>Bun</td>
      <td class="num">396,082</td>
      <td class="num">2.70ms</td>
      <td class="num"><span class="badge badge-slower">1.5x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:9%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>NestJS+Fastify/Node</td>
      <td>JS</td>
      <td class="num">128,475</td>
      <td class="num">21.58ms</td>
      <td class="num"><span class="badge badge-slower">4.6x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:3%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Express/Bun</td>
      <td>JS</td>
      <td class="num">115,804</td>
      <td class="num">8.75ms</td>
      <td class="num"><span class="badge badge-slower">5.1x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:3%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Express/Node</td>
      <td>JS</td>
      <td class="num">91,038</td>
      <td class="num">18.62ms</td>
      <td class="num"><span class="badge badge-slower">6.4x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:2%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>Flask</td>
      <td>Python</td>
      <td class="num">70,951</td>
      <td class="num">18.86ms</td>
      <td class="num"><span class="badge badge-slower">8.2x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:2%"></div></td>
    </tr>
    <tr class="bm-slower">
      <td>FastAPI</td>
      <td>Python</td>
      <td class="num">21,820</td>
      <td class="num">45.37ms</td>
      <td class="num"><span class="badge badge-slower">26.8x slower</span></td>
      <td class="bar-col"><div class="bar" style="width:0.5%"></div></td>
    </tr>
  </tbody>
</table>
</div>
