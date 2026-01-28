---
layout: post
share: true
title: 修改 Jekyll minima 主題的三種方式
---

[Jekyll](https://jekyllrb.com/) 作為 GitHub 內建的 Static Site Generator (SSG)，應該是不少人寫技術型 blog 的入門選擇。另外，Jekyll 的主題 [minima](https://github.com/jekyll/minima) 因為簡單、輕量、快速、易上手，又是 Jekyll 預設主題的特性，也使很多人選擇的風格樣式。

minima 簡單的好處還有一個，也就是修改起來非常容易，不容易碰到 conflict，算是非常好客製化。修改 minima 主題主要有三種方法，從淺到深、從簡單到複雜分別是：

1. [修改 sass 變數](#修改-sass-變數)
2. [覆寫 css 樣式](#覆寫-css-樣式)
3. [修改 source code](#修改-source-code)

這篇文章將會將三種方式都介紹，讓大家自行選擇自己的風格最適合用哪種方法修改。

## 修改 sass 變數

minima 提供不少方便的 sass 變數讓我們可以快速覆寫。

我們首先要在根目錄下創建 `assets/main.scss` 的檔案，並且加上**空白的 frontmatter**，就可以在這裡重新給 minima 提供的 sass 變數重新賦值。並且，在定義完 sass 變數**之後**再 import minima 主題進來：

```scss
// main.scss
---
---

$base-font-size: 18px; // 重新設定字體大小

@import 'minima'; // 之後再 import minima 主題
```

minima 提供了一系列 sass 變數可以修改，以下列出最通用的 minima 2.5.1 版本提供的所有變數（包含預設數值），有興趣可以去[這裡](https://github.com/jekyll/minima/blob/v2.5.1/_sass/minima.scss)看 source code。

```scss
$base-font-family: -apple-system; // 字體樣式
$base-font-size:   16px; // 基本字體大小
$base-font-weight: 400; // 基本字重
$small-font-size:  $base-font-size * 0.875; // 小字字體大小
$base-line-height: 1.5; // 基本行高，單位 em

$spacing-unit:     30px; // 基本空白單位，用於控制 padding, margin 等

$text-color:       #111; // 字體顏色，預設深灰
$background-color: #fdfdfd; // 背景顏色，預設白色
$brand-color:      #2a7ae2; // 連結顏色，預設藍色

$grey-color:       #828282; // 基本灰色，主要控制 blockquote 和 table 背景色
$grey-color-light: lighten($grey-color, 40%); // blockquote, code block, table 的 border 顏色
$grey-color-dark:  darken($grey-color, 25%); // 網站 title 上面那條灰線

$table-text-align: left; // table 的對齊方法

$content-width:    800px; // 文字空間的 max-width

// 最後兩個用在 media-query 上，如果螢幕大小低於設定下面，minima 會變成「好讀版」
$on-palm:          600px; // 轉成手機版的螢幕大小
$on-laptop:        800px; // 轉成筆電版的螢幕大小
```

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i>注意</div>
 minima 不同版本可能會提供不同的變數，特別是最新版的 minima 3.0 以上差異可能更大。GitHub 預設是 2.5.1，但如果你有自己調整版本，請自行透過 `bundle show minima` 前往主題資料夾查詢。
</div>

## 覆寫 css 樣式

如果上面這些變數不能滿足你的需求（這很常見），我們還可以在同一個檔案 `assets/main.scss` 中覆寫 css 樣式。這就會要求我們要有一些基本的 css 知識。不過請注意，css 樣式請寫在 `@import 'minima';` 指令**之後**才能夠覆蓋預設樣式。

例如，我不喜歡 minima 原生的文章列表顯示方式：

![]({{ site.baseurl }}{% link assets/images/minima-default-page.png %}){: width="500" }

透過 inspect element，我發現那些文章標題的 class 是 `post-link`。那我就可以這樣覆蓋樣式：

```scss
---
---

@import 'minima';

.post-link {
  color: #111111 !important; // 改成黑色
  font-weight: bold !important; // 加粗
  font-size: 24px !important; // 加大
}
```

如果發現 css 樣式有 specificity 衝突，我們可以研究如何加強我們 selector 的 specificity，或是直接暴力用 `!important` 覆蓋（就像上面這樣），之後就可以得到像這樣的結果：

![]({{ site.baseurl }}{% link assets/images/customized-minima-theme.png %}){: width="500" }

<div class="callout callout-note" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="pen"></i>提醒</div>
請注意 css 樣式一定要寫在 `@import 'minima';` 之後，但 sass 變數要定義在 `@import 'minima';` 之前。
</div>
## 修改 source code

以上兩種方法應該可以解決 80% 的風格問題，但如果以上兩種都不能滿足你，我們還可以直接從源頭**覆蓋整個 minima 設定檔**。首先，我們要先找到電腦上的 minima 主題在哪裡，先使用以下指令：

```sh
$ bundle show minima 
# returns /Users/me/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/minima-2.5.1
```

這會顯示我們現在使用的 minima 原始碼位置。於是我們就可以進去路徑，找到我們真正想改的元素。

舉例來說，預設文章頁面的日期會附在標題之下：

![]({{ site.baseurl }}{% link assets/images/minima-title-example.png %}){: width="500" }

如果我希望日期出現在標題之上，我就可以到 minima theme 路徑中找到控制 post 頁面的檔案 `_layouts/post.html`。接著，我要**複製整個檔案，並且在我的網頁資料夾複製一樣的路徑**，也就是說，我的網頁資料夾根目錄會也要有一個 `_layouts/post.html`，並且要貼上 minima theme 的內容，之後再對這個檔案做修改。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i>注意</div>
請不要直接修改 minima theme 資料夾中的文件。這會造成兩個問題：
1. 所有的變化會作用在**你所有使用這個 theme 的網站上**，我們只希望 local 覆寫
2. 如果我們更新 minima 的 gem，原本的修改就會被更新覆蓋掉
</div>
我在 `post.html` 裡面找到這個：

```html
<h1 class="post-title p-name" itemprop="name headline">
  {% raw %}{{ page.title | escape }}{% endraw %}
</h1>

<p class="post-meta">
  ...
  {% raw %}{{ page.date | date: date_format }}{% endraw %}
  ...
</p>
```

只要我把 `h1` 標籤移動到 `post-meta` 的下面：

```html
<p class="post-meta">
  ...
  {% raw %}{{ page.date | date: date_format }}{% endraw %}
  ...
</p>

<h1 class="post-title p-name" itemprop="name headline">
  {% raw %}{{ page.title | escape }}{% endraw %}
</h1>
```

再重新啟動網站，就會看到標題改好了：

![]({{ site.baseurl }}{% link assets/images/minima-title-after.png %}){: width="500" }

但是使用這種方法時請務必小心，因為 minima theme 路徑裡面許多檔案可能互相 import，如果沒有修改好可能會出現不預期的錯誤，請謹慎使用。

## 結語

以上就是本篇文章的所有內容，希望大家都能夠好好利用 minima 送給我們的極大自由，將 blog 客製化成最有個人特色的樣子，Happy Blogging!

<style>
img {
  border: 1px solid black;
}
</style>

{% include obsidian-callouts.html %}