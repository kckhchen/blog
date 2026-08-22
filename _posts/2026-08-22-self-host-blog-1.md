---
date: 2026-08-22
generator: intaglio
layout: post
share: true
title: 自架部落格也沒那麼難（一）：無 Ruby 架設 Jekyll 網站
---

部落格寫久了，總會碰到幾個困難點：覺得現有的部落格平台不符合需求、想要有更高的版面自由度、想要有自己的網域⋯⋯通常最終的解法就是回到自架部落格的坑。

自架部落格聽起來很難很複雜，但其實意外的有很多現成的工具可以使用，讓我們在獲得廣大的客製化的同時，不用擔心太多技術層面的東西。今天我就要來介紹一個老牌的自架部落格框架：[Jekyll](https://jekyllrb.com/)。

## Jekyll 簡介

![]({{ site.baseurl }}{% link assets/images/obsidian/jekyll-logo.jpg %}){: width="500" }

Jekyll 是一個靜態網站生成器（Static Site Generator, SSG），也就是不需要後端資料庫或前後端伺服器溝通的輕量網站架構生成器。Jekyll 的主要開發者是 Tom Preston-Werner，同時也是 GitHub 的主要創始團隊的一員。

由於 Jekyll 的 SSG 特性以及與 GitHub 的淵源，使得它作為第一款自架部落格有非常多的優勢，包含：
1. 純 Markdown 支援
2. 免費架站、GitHub Actions 串接免設定
3. 老牌框架，技術及周邊插件生態系成熟

而且，由於可以直接在 GitHub repo 用 Actions 發佈網站的特性，使得我們可以達到本地零依賴，不用安裝任何 Ruby 環境或是 gem 插件就可以開始快速上手寫部落格，改完發布後，過不到一分鐘就可以在自己的部落格網站看到成果。

其他常見的熱門 SSG 包含 [Hugo](https://gohugo.io/)、[MkDocs](https://www.mkdocs.org/) 等等都支援 Markdown 以及快速架站，甚至還有專為 Obsidian 設計的 [Quartz](https://quartz.jzhao.xyz/)，大家也可去參考看看，各有優缺點，不過因為 Jekyll 是我最熟悉的框架以及上述的生態支援優點，在這裡將以這個為主要介紹的對象。

## 快速上手 Jekyll

網路上大多數的 Jekyll 架站教學都會從 `gem install` 或是安裝 Ruby 開始教，不過對於 Ruby 或是寫程式陌生的人來說，就算手把手照做也可能會因為環境依賴問題、版本差異或是不熟悉 Ruby 架構造成許多不必要的麻煩。誠然，能在本地環境架設部落格是進階操作中很重要的一環，不過這會留到未來的教學文章中，現在只要能把 Jekyll 網站架起來，之後就會變得更容易。

因此，這篇文章將會用純瀏覽器架設 Jekyll 網站的方法，教大家如何一步步不透過 command line、不用在電腦上安裝 Ruby 或 gem 就可以輕鬆將部落格上架。

### 1. 找尋喜歡的主題

要開始快速使用 Jekyll，可以先去 GitHub 的 [Jekyll Theme](https://github.com/topics/jekyll-theme) 網站找找自己心儀的部落格樣式。Jekyll 官方也另外在官網[明列了許多可以瀏覽不同主題的網站](https://jekyllrb.com/docs/themes/)，挑到喜歡的就可以開始準備設定工作了。

如果不太知道該從哪裡下手，有許多常用、好入門的主題可以選擇，例如 al-folio、Chirpy 或是 Minimal Mistakes 都是很常見的極簡、功能齊全的選擇。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">提醒</span></div>
就算一開始沒有找到自己喜歡的主題也沒關係，Jekyll 最大的優勢就在於你有 100% 的掌控權，所有畫面設定都可以在日後自行透過 `html` 或是 `css` 設定調整，自由度非常大。

</div>

### 2. 複製一份 template 到自己的 repo

大多數的主題 repo 右上角都會有一個 `use this template` 的按鈕，點下去並選擇 `Create a new repository` 並設定好自己的 repo 名稱就可以了。

![]({{ site.baseurl }}{% link assets/images/obsidian/use-template.png %}){: width="800" }

repo 名稱可以設定為 `<你的github帳號>.github.io`（全部小寫），這是 GitHub 為每個人專門設立的個人網址。到時候部落格設定好後，網站就會出現在 `https://<你的github帳號>.github.io` 上面。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">注意</span></div>
repo 名稱也可以設定為你自己想用的名稱（如 `blog`），這樣的話你的部落格網址就會出現在 `https://<你的github帳號>.github.io/blog` 上面，不過這需要設定 baseurl，請見第四步。

</div>
使用主題時有幾件事情需要留意：

第一，千萬不要選擇 `fork` 主題，因為這會使得你的部落格 repo 和原本的主題 repo 有連動關係，增加不穩定性。

第二，在選擇可見度（Choose visibility）的地方請選擇 Public 公開你的 repo，因為免費方案的 GitHub 只支援幫公開 repo 架設網站。

### 3. 開啟 GitHub Actions 自動部署

在個人網站的 repo 頁面（也就是剛剛開好的 `github.io`），上方導覽列選擇 Settings，側邊欄選擇 Pages，並將 Build and Deployment 的 Source 設定為 **GitHub Actions**。這是目前為止最重要的步驟，只有透過 GitHub Actions 部署網頁才能確保不需要在本地安裝 Ruby gems 進行設定，是最適合入門架站的選項。如果選擇 `Deploy from a branch` 可能會有無法預期的錯誤和困難。

![]({{ site.baseurl }}{% link assets/images/obsidian/page-deploy-action.png %}){: width="800" }

### 4. 編輯 `_config.yml`

這幾乎是網站上架前的最後一步了。repo 根目錄裡面的 `_config.yml` 是這個 Jekyll 網站的大腦。網站的基本資料、網址的顯示方式、我們的個人簡介都會在這裡設定好，這是將網站從「公版」變成「屬於你的網站」的設定空間。

這裡如果你的本地有 git 並且你熟悉 git 的操作的話，非常推薦你 clone 到電腦上之後再進行編輯並且 push 回去。或是如果你只想在瀏覽器上解決，直接在 GitHub 裡面編輯後線上 commit 也沒有問題。

不同的主題會有不同的設定可以調整，不過常見的不外乎就是 `title`（你的網站名稱）、`author`（網站作者姓名）、`description`（網站的主題標語）、`email` 等等，大多數的主題都會先幫我們填好模板，我們只要照著 demo 上面對應的文字去修改就可以了。這部分不同主題需要一點摸索，不過對照網站教學慢慢改應該都不會太過複雜。

要特別注意的是，有一個設定一定要開啟：`timezone: Asia/Taipei`（或是你所在的時區），因為 Jekyll 不會發布未來日期的貼文（見下方），為了避免 GitHub Actions 與我們的時區有差異，設定好之後才不會出現明明是當天發的文，網站上卻看不到的情況。

等 `_config.yml` 設定存檔完後，只要等個十幾秒讓 GitHub Actions 跑完，你的網站應該就會出現在 `<你的GitHub帳號>.github.io` 上了。

設定完後，最新的 commit message 旁邊應該會出現一個橘點，跑完之後應該會是綠色的勾勾。如果這兩個都沒有，去 Actions 頁面也沒有看到運作中的 workflow，可能代表你複製的主題沒有預設 Actions。這時候請去 Actions 分頁 -> 搜尋 "Jekyll" -> 選擇 GitHub 官方提供的 "Jekyll" starter workflow -> Commit 應該就沒問題了。

另外，如果網站沒更新，先去看看 Actions 分頁（或是最新的 commit message 旁邊）有沒有紅色叉叉，有的話就代表部署失敗了，可以點進去看詳細是哪個步驟出錯了。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">注意</span></div>
如果你剛才將 repo 開在自己設定的名稱上（如 `blog`），`_config.yml` 中需要設定你的 repo 名稱，如 `baseurl: "/blog"`，Jekyll 才知道怎麼呈現網址列以及找到你的貼文。設定完成後，你的部落格會跑在 `<你的GitHub帳號>.github.io/blog` 上面，而原本的 `<你的GitHub帳號>.github.io` 則會顯示 404 Not Found，除非你有另外設定個人網站。

</div>
### 5. 上架你的貼文

部落格的架構至此已經完全設定好了，只差自己的貼文了！Jekyll 可以轉換 Markdown 格式變成網站上的內容，因此如果你已經很熟悉用 Markdown 寫筆記或是發文，現在就只差上傳了。

貼文上架之前，需要做幾個處理：

#### 檔名處理

我們要把貼文檔名改成 `YYYY-MM-DD-貼文名稱.md` 的形式。Jekyll 透過前面的日期格式判斷這篇文章的發文日期，並且會把這個檔名作為 url。這裡有幾個不太愉快的坑很容易踩到：

1. 貼文名稱中的空白：如果檔名中有空白，如 `2026-01-01-My first post.md`，Jekyll 在上架後，會把 url 改成 `2026-01-01-my-first-post`，所以會看起來跟原本的檔名不太一樣。不過，即使 Jekyll 會幫我們轉換，還是推薦在一開始上傳前就把檔名中的空白改成 `-`，日後自己要管理也比較方便。
2. 中文名稱可能不能完整顯示：這可能要看 url 使用的編碼，如果網址列不支援中文字元的話，標題名稱可能會變成如 `%E6%96%87%...` 這種稱為 Percent-encoding 的看起來像亂碼的形式，不僅不好讀，也對 SEO 多少有點影響。如果不嫌麻煩的話，把所有貼文檔名改成英文吧！
3. 「未來」的貼文**預設**不會上架：Jekyll 透過 `YYYY-MM-DD` 格式判斷貼文的發文時間，因此如果把日期設定在未來，這篇文章是不會出現在 Jekyll 的網站上的。另外，由於 GitHub Actions 預設的時區是 UTC+0 時區，意味著有些時候就算台灣已經過了12點，GitHub 卻還要八小時才會更新日期，如果馬上發文的話，會發現貼文神隱了。因此剛才才要在 `_config.yml` 中加入 `timezone` 的設定。

<div class="callout callout-note" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="pen"></i><span class="callout-title-text">小提示</span></div>
針對第 2 點，如果不想改檔名，也可以在 frontmatter 中加入 `slug` 設定，讓檔名維持中文，但網址列會是你設定的樣式，詳見下一小節。

</div>
#### Frontmatter 設定

Jekyll 除了檔名以外，也會讀取貼文當中的 frontmatter（元資料）區塊。只要你在 Markdown 檔案**第一行**打 `---`，下面的內容就會變成 frontmatter，直到我們再用 `---` 把 frontmatter 區塊結束為止。

因此，一個 frontmatter 區塊可能會長這樣：

```markdown
---
date: 2026-01-01
title: "My First Post"
slug: my-first-post        # <- 這可以強制 Jekyll 顯示這行字在網址列
---

# 我的文章開頭
```

（如果你使用 Obsidian 寫作的話，其實 frontmatter 就是 Obsidian 的 [properties](https://obsidian.md/help/properties)！）

這裡有點像是每篇貼文專用的 `_config.yml`，在這裡你可以為每篇貼文設定標題、作者、網址列長相等等，這裡的所有設定都會覆蓋 `_config.yml` 中的設定，因此很適合為個別貼文做客製化。不過如果沒有需要客製化的東西的話，也要**留下空白的 frontmatter**：

```markdown
---
---

# 我的文章開頭
```

這樣 Jekyll 才會知道這篇文章需要被處理。

#### 清掉一些貼文雜訊

這個步驟會依照你用的 Markdown 編輯工具而決定複雜程度。Jekyll 支援所有預設的 Markdown 語法，所以 `code 環境` 或是 `[Markdown 連結](https://google.com)` 都會自己渲染，但如果你跟我一樣用 Obsidian 寫作，一些特殊的專門語法，像是 `[[文章連結]]`、`![[快速插入圖片]]`，以及 `> [!INFO]` 等功能都會失效，有些不支援數學語法的主題也不能渲染 LaTeX 語法，使得這些語法會在網站上呈現醜醜的原本長相。

這點可能是許多人眼中最麻煩的步驟，畢竟這一路做下來，你要做的事情可能包含：

- 把用到的圖片一張張複製到 `assets/images/`
- 把每個 `![[螢幕截圖.png]]` 改成 `![](/assets/images/螢幕截圖.png)`
- 把 `[[另一篇筆記]]` 改成真的連結，或者直接拿掉
- 把 callout 全部改成普通引用區塊
- 檔名加日期、frontmatter 補齊

而且現在要管理兩份貼文：Obsidian 裡面的，還有 Jekyll 裡面的。不過幸好現在有許多工具都被設計來專門解決這個問題，我們[下一篇文章]({{ site.baseurl }}{% link _posts/2026-08-22-self-host-blog-2.md %})會談到。

#### 將貼文移到 `_posts`

Jekyll 大多數主題中都會有一個 `_posts` 的資料夾，那就是所有要發布的貼文的家。只要將上方整理好的貼文放進 `_posts` 資料夾中（在本地放的話記得 push），等待 Actions 跑完，我們的貼文就會美美地出現在部落格網站上了！

如果你的貼文裡面含有圖片，也可以將圖片一起複製到部落格 repo 的 `assets/images/` 資料夾中，並把貼文裡的圖片連結都換成 `![](/assets/images/<圖片名稱>.png)`

### 6. 客製化自己的網域（非必要）

如果你有在 Cloudflare 或其他地方買了專屬自己網域，可以把自己的網域串接到 GitHub Pages 上面去，讓網站更有個人風格。不過由於相關細節繁瑣，這裡就先不提了，詳細可以去 repo 的 Settings -> Pages -> Custom domain 看詳細說明跟設定方法。

## 結語

自己架站真的沒有那麼難！雖然前前後後感覺也寫了不少步驟，做了很多麻煩事，不過好消息是這些設定都是**一次性的**，一旦把 Jekyll 架設好，除非想要後續調整部落格風格或是更進階的設定，否則從現在開始，發文的成本就變成「寫，整理，上傳」三個步驟，之後等 Actions 跑完就可以讓自己和所有人在網路上看到自己的貼文了！

至於發文的流程能不能再更簡化？如果我不想要每次手改檔名、加 frontmatter 有沒有更有效率的做法？那些好用的 Obsidian Markdown 語法真的不能用嗎？好消息是，這些東西都有現成的工具可以快速解決，準備好的話，就可以到[下一篇文章]({{ site.baseurl }}{% link _posts/2026-08-22-self-host-blog-2.md %})看看怎麼設定了！

{% include obsidian-callouts.html %}