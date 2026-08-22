---
date: 2026-08-22
generator: intaglio
layout: post
share: true
title: 自架部落格也沒那麼難（二）：從 Obsidian 到 Jekyll 自動化發布機制
---

<div class="callout callout-note" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="pen"></i><span class="callout-title-text">寫在前面</span></div>
這篇文章主要寫給和我一樣用 Obsidian 寫作，並使用 Jekyll 架設部落格網站的人，因為這篇文章聊到的工具對這兩個工具都有專一性，因此如果這不符合你的需求，歡迎直接去讀我的[第三篇文章]({{ site.baseurl }}{% link _posts/2026-08-22-self-host-blog-3.md %})，那裡會有進階的 Jekyll 用法可以讓架設部落格變得更流暢！另外，這篇文章需要你對 Git 以及 GitHub 有基本的操作知識會比較容易跟上。

</div>
上一篇文章我們談到如何利用 Jekyll 快速架設屬於自己的部落格網站。如果你已經把上一篇照做完了，應該已經有一個功能齊備的個人部落格了，恭喜你！

不過，當我們開始發文後，就會開始發現一些麻煩的小事，特別是如果你跟我一樣用 Obsidian 寫文章的話，那就是在發文前還要把文章整理好，包含複製圖片、改連結、改 callout、改檔名、補 frontmatter 等等，而且現在每次想要修改文章，就要在自己的 vault 修一次，又要在 `_posts` 裡面的貼文改一次。幸好，這些東西其實都是固定的流程，可以通過自動化解決這些痛點。

跟著這篇文章把設定走完之後，我們未來發文的流程就只要在 Obsidian 的屬性面板中打一個勾就幾乎完成了。

## 先看工具做了什麼

在有工具之前，由於 Obsidian 的 callout `> [!INFO]` 或是 `[[內部連結]]` 都不支援，有些主題也不支援數學語法，所以如果不自己處理的話，我們的畫面可能會長這樣：

![]({{ site.baseurl }}{% link assets/images/obsidian/intaglio-broken.png %}){: width="600" }

現在有了這份工具之後，什麼都不用做，只要打勾 `share`，push 上去，就可以在 Jekyll repo 收 PR，合併更新後，畫面就會自動變成這樣：

![]({{ site.baseurl }}{% link assets/images/obsidian/intaglio-fixed.png %}){: width="600" }

這個工具叫做 **[Intaglio](https://github.com/kckhchen/intaglio)**，是我為了自己的部落格寫的免費開源工具。

## 怎麼設定 Intaglio

這份工具可以在本地運行，也可以透過 GitHub Actions 串接，我比較推薦後者，在這裡也會以後者為主要介紹對象，因為單次設定好之後，未來就不用再打任何指令，也不用進行任何設定了。

### 1. 設定 Obsidian Vault repo

首先，你需要將你的 Obsidian Vault 也上傳到一個獨立的 GitHub repo 上，可以設定為 private，這樣就算你的私人筆記在雲端也不會被別人看到，而且還有順便備份的好處。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">注意</span></div>
要將 Obsidian Vault 上傳到 GitHub repo，本地也會有 Git 要管理，請注意不要將 Obsidian 放在同步到 iCloud 或是 OneDrive 的資料夾，否則 Git 裡面千千萬萬個小檔會讓雲端同步塞住。GitHub 正好可以替代雲端的備份功能。如果你真的不想讓 Obsidian vault 上 GitHub，Intaglio 也有提供 CLI 介面在本地使用，歡迎參閱[repo 網站](https://github.com/kckhchen/intaglio)。

</div>
因此現在的你應該會有兩個 repo，私人的 Obsidian repo 儲存你的私人筆記，以及公開的 Jekyll repo 儲存你的部落格文章。

### 2. 生成並儲存 Token

為了讓 Action Bot 可以編輯你的 Jekyll repo（幫你轉換 Markdown）以及開 PR，我們需要給它 Token。

從右上角自己的頭像點開 -> Settings -> 側邊欄最下面的 Developer settings 點進去後，選擇 Personal access tokens 下面的 **Fine-grained tokens**，選擇 Generate new token。

把 token 的標題跟描述打好（寫一些自己會記得這是拿來幹嘛的標題跟描述）。之後的權限選擇是最重要的：
1. Repository access 請選擇你的 **Jekyll repo** （不是 vault repo）
2. Permissions 部分要給兩個：Contents 以及 PR，都要給 **Read and write** 權限（如圖）

![]({{ site.baseurl }}{% link assets/images/obsidian/pat-screenshot.png %}){: width="800" }

之後你會得到一個 token 字串：

![]({{ site.baseurl }}{% link assets/images/obsidian/token-preview.png %}){: width="800" }

請把它**馬上複製下來**，它只會顯示這一次。之後回到你的 vault repo，進入導覽列的 Settings -> 側邊欄 Secrets and variables 的 Actions，新增一個 repository secret，標題輸入 `BLOG_PUSH_TOKEN`，內文就貼上剛剛的 token 字串，儲存後就完成了，你應該會看到有一個新的 token：

![]({{ site.baseurl }}{% link assets/images/obsidian/blog-push-token-preview.png %}){: width="800" }

### 3. 創建 `yml` 檔案

在 vault repo 裡面建立一個 `.github/workflows` 的資料夾，並在裡面創建一個 `publish.yml` 的檔案，裡面貼上這串 code：

```yaml
name: Publish
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: kckhchen/intaglio@v1
        with:
          jekyll-repo: username/jekyll-repo       # <- 這邊改成你的 Jekyll repo
          token: ${{ secrets.BLOG_PUSH_TOKEN }}
          args: --update --force --yes
```

存檔 commit 後就完成了！過程雖然看起來有點繁瑣，但這就跟 Jekyll 架站一樣是一次性的工作，從設定完後的那一刻，我們的發文工作流變成超級簡單：

1. 自然用 Obsidian 寫文章，想用什麼語法就用什麼語法，不用改檔名
2. 在 frontmatter (properties) 加上 `share: true`（或是打勾），並加上日期 `date: YYYY-MM-DD`
3. commit & push

<div class="callout callout-note" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="pen"></i><span class="callout-title-text">為什麼日期是必填的</span></div>
如果沒填，工具只能去問作業系統這個檔案什麼時候建立的，而 GitHub 每次抓下來的檔案時間都是當下——日期會變、檔名會變、你分享出去的連結就死了，所以工具會在發布前直接擋下沒填日期的文章，不讓它偷偷上線。

</div>
這份 Action 就會自動啟動，把所有文章換成 Jekyll 可以呈現的形式，並且開一份 PR 到你的 Jekyll repo，你只要回到 Jekyll repo 審閱過之後 merge，你的文章就更新上去了！如果 push 完之後遲遲沒收到 PR，先去 **vault repo** 的 Actions 分頁看最新一次執行，紅叉點進去可以看到卡在哪一步。

第一次跑的時候，所有標記了 `share: true` 的筆記會一起被處理，所以那個 PR 可能會很大。另外，如果你上一篇已經手動放了一些文章進 `_posts`，而且 vault 裡也有對應的原稿，那些檔案會被工具產生的版本覆蓋——這是正常的，之後 vault 就是唯一的正本了。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">如果你的網址是 `username.github.io/blog` 這種形式</span></div>
也就是第一篇有設 `baseurl` 的話，合併 PR 後如果發現圖片破圖、連結變成 `/blog/blog/...`，在 workflow 加一行就好：`prevent-double-baseurl: true`

</div>
## 這個工具幫你做了什麼

|    我在 Obsidian 裡寫的     |       網站上長出來的        |
| :--------------------: | :------------------: |
| ![]({{ site.baseurl }}{% link assets/images/obsidian/obsidian-demo.gif %}){: width="400" } | ![]({{ site.baseurl }}{% link assets/images/obsidian/jekyll-demo.gif %}){: width="400" } |

這整套工具其實做的事情很簡單，它幫你把所有 Obsidian 特有的 Markdown 語法，一一轉換成 Jekyll 特有的語法（Liquid tags），也把 callout 轉換成可以解析的 html 語法，並且把所有文章內的圖片也一起複製過去 Jekyll repo。

| 你在 Obsidian 寫的 | 網站上變成       |
| -------------- | ----------- |
| `[[另一篇筆記]]`    | 可以點的連結      |
| `![[截圖.png]]`  | 圖片複製過去，連結改好 |
| `> [!tip] 標題`  | 有圖示有顏色的提示框  |
| `$E=mc^2$`     | 正常渲染的公式     |
| 檔名、frontmatter | 自動補齊        |

而且你只要在 Obsidian 刪除文章或是下架（把 `share` 關掉），重新 push 之後，文章也會在 Jekyll 下架。

最重要的是，整個過程中，你的 Obsidian 貼文一個字不會被碰、被改。因此你的原本貼文安安穩穩地住在 vault 裡面，要給別人看的貼文已經改好放進 Jekyll 的 `_posts` 裡面了，也就是你們在 [前面這個章節](#先看工具做了什麼)看到的模樣。另外，如果你的 Jekyll repo 已經有發過的舊文，這個工具也不會去動它，不會把你的舊貼文吃掉。

## 這個工具不會做什麼

雖然這工具在文字處理上十分有效率，但也不是萬能的。畢竟它不像其他常見的 Obsidian 發布工具一樣整個 vault 發上去，因此 Obsidian 筆記本身文字內容以外的 dataview、canvas、graph view、backlink 都不支援。這是這份工具在「維護 Jekyll 部落格樣式」以及「Obsidian 原生體驗上網」之間所做的取捨。

## 你還有其他選項

如果你是從第一篇進來的，可能已經有 Jekyll 網站了，所以下面這些其他工具可能不太適合你，但如果你跟我有一樣的困擾（想用 Obsidian 語法寫作並發表），而且還沒決定好要用哪個部落格框架，其實還有其他網路上熱門的工具可以參考：

### Enveloppe

[Enveloppe](https://github.com/Enveloppe/obsidian-enveloppe) 跟 Intaglio 有點像，都是 Markdown 到 SSG 語法的轉換工具，而它最大的優點也正好是最大的缺點：它支援多種 SSG。這意味著無論你的部落格框架是 Jekyll、Hugo 或是 MkDocs，它都可以相容，但這也意味著它必須取得這些 SSG 的最大公約數，所以框架沒有原生支援渲染的（如 callouts，或是有些 Jekyll 主題不原生支援數學公式），轉換上去之後還是一團原始字串。

它的另外一個優勢是它活在你的 Obsidian 裡面作為一個插件，因此可以滿足「一鍵發佈」，不用你手動 commit & push。

它適合不太使用 Obsidian 特殊語法的人，或是想要每款 SSG 都試試看的人。

### Quartz

[Quartz](https://quartz.jzhao.xyz/) 可以說是 Obsidian 部落格生態中最強勁的競爭者。它不是一個轉換器，而是自己就是一個 SSG，幾乎可以把整個 vault 原封不動搬到網路上。也支援 Obsidian 的 graph view 以及大多數特殊語法，並且因為它重建「第二大腦」的哲學，使得你的部落格就看起來與自己的 vault 十分相似。

如果你還在摸索要用哪個方法自架部落格，我覺得 Quartz 會是一個非常值得嘗試的選項，因為它對 Obsidian 的原生支援性是數一數二好的。不過，Quartz 的插件和主題支援就沒有 Jekyll 或其他老牌 SSG 那樣豐富，這意味著你如果對自己的部落格很有掌控欲，想要完全客製化，在 Quartz 實現上會比較困難，因為它用自由度換了方便性。

另外，Quartz 複製 Obsidian vault 的模式大家是否喜歡也見仁見智，我個人喜歡部落格的傳統樣貌：每篇文章都是獨立的 entry。這也是我當初沒有選用 Quartz 選擇用 Jekyll 自架的原因——我希望我可以輕鬆用 html/css 就掌握我的部落格長相，不用去原始碼深處翻設定。

### Obsidian Publish

這有可能是所有用 Obsidian 的人都考慮過的管道，Obsidian 官方提供的一條龍發文服務。這個工具其實跟 Quartz 所生成的網站蠻像的，都是以 vault view 為基礎作為發布風格。不過它最大的缺點就是要花錢。一個月 8 美元的訂閱價格，在茫茫免費開源部落格框架的紅海中顯得有點過於昂貴。

而且自架部落格無非就是想要對自己的部落格有完全的掌控權，使用 Obsidian Publish 只買到了服務，沒有得到渲染後的實體檔案不免也覺得有點可惜。

Obsidian Publish 的定位很明確：適合沒有深厚技術背景，或是不想花時間研究開源 SSG 的 Obsidian 忠實用戶。

## 結語

最後謝謝你一路看到這邊。從 Obsidian 寫作到 Jekyll 發文，我也是踩了很多坑才走到這一步，找到自己最輕鬆的工作流程。每個人都一定有最適合自己的方法，也沒有一個方法可以滿足所有人，因此這篇文章不僅僅是想和你分享我研究出來的結果，也希望你能藉此找到更多好用的工具，讓自己的 blogging 之路更順利。

如果想要更了解我做的 Intaglio 工具，歡迎到 [repo 頁面](https://github.com/kckhchen/intaglio)去看看更多設定，有問題也歡迎開 issue，我會盡快解決。

{% include obsidian-callouts.html %}