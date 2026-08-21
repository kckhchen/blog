---
date: 2026-08-19
generator: obsidian-2-jekyll
layout: post
share: true
title: 自動化版控 release-please 從入門到進階（一）：SemVer 和 Conventional Commits
---

當開發程式到一段時間，工具越來越多人使用後，就會開始有版本管理的需求。Google 開發的 `release-please` 正是為此而生的自動化版控工具，可以輕鬆透過 GitHub Actions 發布、管理 release 版本。這篇文章將會介紹其功能、用法，以及注意事項。

## 前提

要使用 `release-please` 進行版本管理，我們需要先知道什麼是 Semantic Versioning (SemVer) 以及 Conventional Commits。對這兩個概念有基礎認識對未來使用 `release-please` 或是其他任何自動化版本管理工具都特別重要。

### 語義化版本（Semantic Versioning, SemVer）

[SemVer](https://semver.org/) 是一種標準化的版本撰寫風格，使得版本號中的每一個數字都有其代表意義，不僅使得版本號更容易被理解，也可以使工具使用者知道哪些情況可以安全更新工具版本，哪些情況需要注意 backward compatibility。

SemVer 規範的版本號必須是 `X.Y.Z` 的形式，其中 `X` 稱為主版號（major）、`Y` 稱為次版號（minor）、`Z` 稱為修訂號（patch）。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">補充</span></div>
git tag 慣例上會加上 `v` 前綴，也就是 `vX.Y.Z`。稍後會看到 `release-please` 的預設行為也是加上 `v` 前綴，因此以下會用 `vX.Y.Z` 來指涉版本號

</div>
SemVer 規定能夠更新版號的情境如下：
1. 當新版本僅包含錯誤修訂（bug fixes）時，更新 patch（例如：`v1.1.0` -> `v1.1.1`）。
2. 當新版本包含新功能提交時，更新 minor（例如 `v1.1.3` -> `v1.2.0`）。
3. 當新版本出現破壞性改動（breaking change），也就是讓舊版本號無法相容的更動時，更新 major（例如 `v1.3.1` -> `v2.0.0`）。

只要開發者遵守 SemVer 規範進行版號更新，使用者一看版本號碼就可以迅速判斷自己是否適合進行更新，舉例而言：
1. patch 通常可以立即更新，並且建議更新，因為涉及到錯誤修復。
2. minor 如果沒有包含其他錯誤修復，可以依照新功能需求考量是否更新。
3. major 需謹慎考量更新需求，因為有些原先的設定或是使用模式可能因為 backward compatibility 而失效。

另外，考量到開發初期的 breaking changes 可能有很多，SemVer 也對 major 為 `v0.y.z` 的版本命名另有說明。通常 `v1.0.0` 會被視為正式版，所以在開發穩定（SemVer 定義為公開 API 已穩定）前的 `v0.y.z` 版號都視為初期開發，任何東西都可能隨時改變，因此沒有特別設立規定。社群慣例上，所有的新功能和錯誤修復都只會更新 patch，而只有 breaking change 會更新 minor。因此面對快速迭代期間，使用者可以依賴 minor 來判定有沒有破壞性變更。

現今大多數的自動化版本管控工具都會依循 SemVer 的規範，因此若對此有基本了解，可以讓開發過程更順暢、版本號更有意義。

### 慣例式提交（Conventional Commits）

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) 是一種 git commit 的撰寫標準化風格，給開發者一個一致、客觀、可遵循的 commit message 寫法指南。因為幾乎每個自動化版本管理工具都會透過閱讀 commit messages 來決定要更改哪個版號，又或是是否要開版號，因此善用 Conventional Commits 可以幫自己以及自動化腳本都省下非常多心力。

Conventional Commits 對於 Commit Messages 的寫法規範如下：

```
<commit 種類>[適用範圍（選填）]: <commit 描述>

[commit 細節（選填）]

[commit 腳註（選填）]
```

`<commit 種類>` 有兩個基本選項可以選擇：`fix` 代表錯誤修復、`feat` 代表新功能，因此一個最基本的 Conventional Commit 可能可以長這樣：

```
feat: add login page
```

另外，如果 commit 涉及到破壞性的重大改變，我們可以在種類後面加上一個驚嘆號 `!` 代表 breaking change，或是在腳註中另外寫明 `BREAKING CHANGE`：

```
feat!: drop support for python 3.8

BREAKING CHANGE: dependencies only compatible with Python 3.9 and above
```

我們也可以透過適用範圍（scope）註明這個 commit 的作用範圍：

```
feat(ui): refresh profile page
```

如果 scope 和 breaking change 一起出現，則 `!` 要寫在 scope 後面：

```
feat(api)!: Switch to FastAPI
```

以上大概就是最簡單的 Conventional Commit 寫法。其實 Conventional Commits 除此之外並沒有特別嚴格的規範（種類有哪些、是否要寫細節、大小寫等等），重要的是，一個協作團隊中必須彼此講好，保持一致性。例如開源社群常遵循的 [Angular Convention](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) 就羅列了其他常用的 commit 種類，如 `refactor`（重構）、`style`（程式碼美化）、`chore`（雜務）等等。

## release-please 入門

有了上面兩個基本知識之後，`release-please` 的使用就很簡單了，先談談它的運作規則再聊聊怎麼使用它。

### 版控機制

`release-please` 是一個 GitHub Action Bot，一旦偵測到有新的 push 就會喚醒，檢查 commit 歷史中有沒有 `feat`、`fix` 等會提升版號的更新或是 breaking change，再依照 repo 規則以及現在的版本號決定要開 PR 提升哪一個版本號。如果自上一次 release 以來，中間經歷過 `feat` 的 commit，它就會提升 minor digit；如果中間只有經歷過 `fix` commit，就只會提升 patch digit；當然，如果出現 `feat!` 或是 `fix!` 這種破壞性的重大變更，就會提升 major digit。其中的這些改動同時也會寫進 `CHANGELOG.md` 方便未來參考。

反之，如果是與使用者體驗無關的 `style`、`test` 等等類型的 commit，除非有 breaking change，否則不會觸發 `release-please`，也不會被寫進 Changelog，背後的理由很簡單，因為 release 是以使用者為導向的版本發布，這些東西無關使用者看到、體驗到的內容，自然就不會更新版本。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">補充</span></div>
所有官方預設會觸發 release 的種類如下：`feat`（或 `feature`）、`fix`、`perf`、`revert`
而所有其他 commit 種類只要有 `!` 注記重大變更，也會觸發 release，其中官方事先提供 section 標題的有：`chore`、`docs`、`style`、`refactor`、`test`、`build`、`ci`

</div>
這些是 `release-please` 的預設行為，全部都可以依照需求客製化，這些我們會在[下一篇文章]({{ site.baseurl }}{% link _posts/2026-08-20-release-please-2.md %})提到。

當 `release-please` 決定好版本升級方向之後，會自己在 GitHub repo 上開一個 branch 並開 PR 給我們，看起來會像這樣：

![]({{ site.baseurl }}{% link assets/images/obsidian/release-please-pr-screenshot.png %}){: width="500" }

可以發現所有的更新內容都已經幫我們寫好、分類好、排版好了。我們只要審核過之後，按下 Merge PR，我們的 main 就會有新的 release 了！

如果我們還沒有準備好發新的 release 怎麼辦？`release-please` 也十分貼心，只要我們不 merge，之後再把新的改動 push 上來，它就會回去編輯那個 PR，等我們準備好之後再一次 merge 就好。


### 使用方法

由上可以知道 `release-please` 是利用 Conventional Commit 的前綴進行版控決策，並且預設依照 SemVer 規範進行版本升級。實際上要怎麼使用呢？最簡單的版本需要創建三個檔案：GitHub Action 的 `.yml` 檔案、版控設定的 `release-please-config.json`、以及紀錄版本的 `.release-please-manifest.json`。

最簡單的 `.yml` 檔大約會長這樣：

```yml
# .github/workflows/release-please.yml
name: Release Please

on:
  push:
    branches:
      - main # 或依照 repo 性質改成 master

permissions: # 給予 Action Bot 修改檔案和創建 PR 的權限
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - name: Run Release Please
        uses: googleapis/release-please-action@v4 # release-please api
```

這樣就完成了！這個 `.yml` 檔案要記得放在 repo 下的 `.github/workflows` 目錄中才會被偵測並執行。另外，我們可以在 repo 根目錄創建一個設定檔，告訴 `release-please` 更新版號的規則：

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "simple"
    }
  }
}
```

`release-type` 對應多種不同語言 package 的版本更新方式，包含 `python`、`ruby` 或是 `node` 等等，會自動更新 packages 中的版號，但如果只是散裝的 CLI 工具，用最基本的 `simple` 就可以了。其他更進階的設定會在[下一篇文章]({{ site.baseurl }}{% link _posts/2026-08-20-release-please-2.md %})提到。

最後，我們需要一個 manifest 檔案告訴 `release-please` 該從哪一個版本開始作為更新版號的基礎，這時候就會需要在根目錄創建一個 `.release-please-manifest.json`，裡面只有短短一行設定，標注目前**已發布**的最新版號，例如：

```json
{
  ".": "0.2.0"
}
```

這可以讓 `release-please` 接手更新下去。並且，在未來更新版本號時，工具也會順帶更新這個 manifest 檔案，所以一次設定後就可以不用管他了。如果 repo 是沒有任何版號的全新狀態，則可以填寫 `0.0.0`。

<div class="callout callout-important" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="flame"></i><span class="callout-title-text">注意</span></div>
請務必確認已發布的版號真的有對應的 git tag 或是 release，否則 `release-please` 會從第一個 commit 開始建構 Changelog，導致 Changelog 被塞爆。

</div>
最後，千萬要記得在 repo 上面給 Action Bot 開 PR 的權限。在 repo 頁面進入 Settings -> Actions -> General，滑到下面去之後把 **"Allow GitHub Actions to create and approve pull requests"** 設定給打勾就可以了：

![]({{ site.baseurl }}{% link assets/images/obsidian/allow-pr-screenshot.png %}){: width="500" }

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">小提醒</span></div>
上面那個 "Read and write permissions" 如果沒有其他特殊原因建議不用打開。我們在 `.yml` 檔中已經給了 Action 編輯和開 PR 的權限了，所以這裡可以保持關閉，保持 repo 安全。

</div>
這樣就是最基本的 `release-please` Action 設定！之後每次只要 merge 或是 push 到 main，這個 Action 就會自動啟動，發布新版號的 PR，更新 manifest，並且生成一個 `CHANGELOG.md` 追蹤所有更新細節了！

要再特別注意的是，由於 `release-please` 會讀所有的 Conventional Commits，如果有開 PR 再 merge 新功能或維修的習慣，請盡量使用 squash merge，避免中途那些無關的 commit 也一起被涵括進 Changelog 裡面。而 squash merge 之後的 commit message 預設會是 PR title，所以也要符合 Conventional Commits 格式。

當然，這只是 `release-please` 強大功能跟設定的冰山一角，更進階的使用方法我們會在[下一篇文章]({{ site.baseurl }}{% link _posts/2026-08-20-release-please-2.md %})談到。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">小提醒</span></div>
`release-please` 預設行為是不會套用前面所說的 `v0.y.z` 的社群慣例的，需要特別修改 `release-please-config.json` 進行設定，下一篇一樣會提到。
</div>

{% include obsidian-callouts.html %}