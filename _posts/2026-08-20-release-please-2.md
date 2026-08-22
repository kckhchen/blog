---
date: 2026-08-20
generator: intaglio
layout: post
share: true
title: 自動化版控從入門到進階（二）：release-please 進階用法和設定
---

在[上一篇文章]({{ site.baseurl }}{% link _posts/2026-08-19-release-please-1.md %})中我們了解了 Conventional Commits 以及 SemVer 的概念，以及這兩個規範如何與 `release-please` 協作進行自動化版控。這篇文章將會專注在 `release-please` 的強大進階功能和設定，讓大家的使用體驗更順暢。

## 進階設定：Pre-Major 版本管理

上一篇文章中有提到 SemVer 對於開發初期快速迭代的 pre-major 時期不特別設立升級規範，而社群慣例是將 `feat` 和 `fix` 統一歸類在 patch 版號提升（`v0.1.1` -> `v0.1.2`），而 breaking change 將會歸類在 minor 版號提升（`v0.1.0` -> `v0.2.0`）。這是為了避免頻繁有 breaking change 的開發初期不小心升級到主要版號，造成非刻意的「正式版」發布。當然 `release-please` 也幫使用者考慮到了這件事情，我們可以透過兩項 `release-please-config.json` 中的設定控制這個行為：

```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true
    }
  }
}
```

其中的 `"bump-minor-pre-major": true` 會確保就算是 breaking change 也只會動 minor digits，而 `"bump-patch-for-minor-pre-major": true` 則是進一步將原本會動 minor digits 的更新（也就是 `feat`）推縮到 patch digits 上面。當然，這個設定只會在 major 版號為 0 的時候生效，一旦手動升級到 `v1.0.0` 以上就會自動失效了。

也就是說，就算出現新功能，版號提升也可能只會從 `v0.1.2` 升級到 `v0.1.3`，而如果出現 breaking change，版號也只會推高到 `v0.2.0`，確保工具常態保持在 `v0.y.z` 的版號規格上，不會意外升級到 `v1.0.0`。

這兩個設定也不一定要一起使用。我們可以移除 `bump-patch-for-minor-pre-major`，這樣的話就會使得 `feat` 和 breaking change 都會提升 minor digits。下面的表格可以作為快速比較的參考，假設目前的版本號是 `v0.1.2`：

| 設定                        | `fix`   | `feat`  | `feat!` |
| ------------------------- | ------- | ------- | ------- |
| 預設行為                      | `0.1.3` | `0.2.0` | `1.0.0` |
| 設定 `bump-minor-pre-major` | `0.1.3` | `0.2.0` | `0.2.0` |
| 兩個設定都開                    | `0.1.3` | `0.1.3` | `0.2.0` |

### 控制進 Log 的 Commit 種類

雖然 `release-please` 原生只會偵測 `feat`、`fix`、`perf`、`revert` 等更動或是 breaking change，也只會將這些改動寫入 Changelog，但我們也可以手動設定哪些 commit 也要被偵測、觸發 release PR，並可以被一起寫進 Changelog，甚至可以自己創造不同的 commit 種類，只要在 `release-please-config.json` 檔案中加入追蹤清單就好：

```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "changelog-sections": [
        { "type": "feat", "section": "New Features" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "ui", "section": "UI changes", "hidden": false },
        { "type": "style", "section": "Code Style Change", "hidden": false }
      ]
    }
  }
}
```

其中 `type` 的部分是設定要偵測哪些 commit 種類會觸發 release 並寫進 Changelog，`section` 則是控制 Changelog 裡面的標題寫法，最後的 `hidden` 是最終決定要不要寫入的開關：只要設定為 `false`，帶有這些種類的 commit 內容如果 push 上去，就會觸發新的 release，並寫進 Changelog 裡面。

另一方面 `"hidden": true` 的 commit 種類雖然不會進 Changelog 也不會觸發 release，但如果有加上 breaking change 的 `!` 就會覆蓋設定，觸發 release 並寫進 Changelog。

<div class="callout callout-important" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="flame"></i><span class="callout-title-text">注意</span></div>
`changelog-sections` 一旦有自訂內容，就會完全覆蓋原始設定，因此一定要寫上 `feat` 和 `fix`。若有其他預設會觸發的 commit 種類也要加進去，例如 `perf`、`revert` 等等。而沒被列進清單的種類，如果加上 `!` 也會觸發 release，但 section 名稱會變成原始種類名。

</div>
### 設定 PR 標題和描述

我們也可以自行設定當 `release-please` 開 PR 時要有哪些描述。以下可以設定 PR 標題和 header，到時候 Bot 就會根據你的需求開更好閱讀的 PR 了。

```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "pull-request-title-pattern": "chore: 發布 v${version}",
      "pull-request-header": "請合併我！"
    }
  }
}
```

以上這些是我個人開發上最常用的功能，不過[官方文件](https://github.com/googleapis/release-please/blob/main/docs/customizing.md)中其實有更多更複雜的功能，由於篇幅以及熟悉度問題，我這裡就不多講了，歡迎有興趣的各位自己上去查閱。

## 手動版控

也有些時候，我們會希望手動決定這個 commit 應該上到哪一個版本。例如我們基於重大更新，希望跳過一些版號，或是想要手動將某個更新定義為正式版，卻希望保持 pre-major 的設定，那我們就可以在 Conventional Commit 的腳註透過 `Release-As:` 標籤手動設定版本號：

```
feat: add new payment gateway

Release-As: 2.0.0
```

當 `release-please` 逐一讀取 commit message 時，就會自動將下一版本定為 `v2.0.0`，覆蓋所有現有設定的限制。

除此之外，如果在沒有 `feat` 或是 `fix` 的 commit 之間也希望手動控制版本，`Release-As` 也派得上用場：

```
git commit --allow-empty -m "chore: release 2.0.0" -m "Release-As: 2.0.0"
```

透過 `--allow-empty` 的 flag 可以發送一個不帶 diff 的 commit，而且 `Release-As` 的腳註也可以無視 commit 類型強制觸發新的版本號更新（但會寫進 Changelog）。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">補充</span></div>
當有多個帶有 `Release-As` 的 commit 聚集在同一次 release 時，最新的 commit 所帶的 `Release-As` 版本號會生效。commits 是由新到舊處理的。

</div>
## 自動更改程式碼中的版號

這或許是 `release-please` 最強大的功能之一。如果在開發 app 或是網站時，我們會習慣同時提供版號在畫面上讓使用者知道，但是這部分能不能自動化呢？答案是可以的！`release-please` 可以依照使用者設定，在指定檔案找出版號位置，依照標記自動替換成最新版號，包在同一個 PR 裡面讓我們 merge，達到完全的自動化，從此以後不用再手動改 app 上面的版號了！

首先，我們需要先將含有版本號欲修改的檔案加入 `extra-files`：

```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "extra-files": [
        "dist/index.html",
        "README.md"
      ]
    }
  }
}
```

之後回到程式碼進行版號位置標記。我們可以在程式碼中插入註解字串，讓 `release-please` 自動找尋、替換，主要有兩種方法，在這裡我使用網頁原始碼 `.html` 示範：

```html
<footer>
  <p> 
    Current Version: 
    <!-- x-release-please-start-version --> 
    1.0.0 
    <!-- x-release-please-end -->
  </p>
</footer>
```

我們透過註解的 `x-release-please-start-version` 以及 `x-release-please-end` 字串夾住版本號，`release-please` 偵測到之後就會自動將裡面的版本替換成目前的最新版本。

另外，也有單行的寫法：

```html
<span class="version">v1.0.0</span> <!-- x-release-please-version -->
```

此時 `release-please` 會尋找該行中**第一個**版本號字串，並替換成最新的版本號。

至於裡面的版號可以隨意填寫，只要符合合法的 `X.Y.Z` 格式就可以了，反正經過一次 PR 後就會被 `release-please` 抽換成正確的版號。

## 結語

這樣就大功告成了！只要將所有的進階設定調整好，`release-please` 就會是我們強大的幫手，不只可以為版本把關，自動推新版號，還可以全自動抽換原先程式碼內的版本號，讓開發者只要專心維護、開發新功能，不用花上大把時間寫 tag、寫 release、管 SemVer，還有在程式碼海中找到那幾個可能不小心遺忘的版本號，手動修改過來了。

另外 `release-please` 其實還有更多高手功能可以使用，不過已經不在我的專業範疇內，我就不多談了。詳細的高級功能歡迎直接去 [GitHub 原始碼 repo](https://github.com/googleapis/release-please/) 了解。

如果你已經看完這篇文章，想回去複習我談到的 Conventional Commits 或是 SemVer 的注意事項，歡迎回到[上一篇文章]({{ site.baseurl }}{% link _posts/2026-08-19-release-please-1.md %})查看我寫的內容。

{% include obsidian-callouts.html %}