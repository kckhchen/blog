---
date: 2026-08-22
generator: intaglio
layout: post
share: true
title: 自架部落格也沒那麼難（三）：在本地環境預覽 Jekyll
---

在[第一篇文章]({{ site.baseurl }}{% link _posts/2026-08-22-self-host-blog-1.md %})中我們聊到本地不用安裝 Ruby 就能快速架部落格的方法，在[第二篇文章]({{ site.baseurl }}{% link _posts/2026-08-22-self-host-blog-2.md %})中看到了結合 Obsidian 的全自動發文工作流。雖然不用 Ruby 就可以在 GitHub 上面架部落格很美好，但久了之後總會碰到一些問題：有可能我們想在本地預覽過文章後再發表，或者我們在不停修修改改部落格編排時，不想一直等 Actions 跑二三十秒才能去看（更別提讀者可能會實時看到你在改網站），所以就像所有網站開發一樣，我們也會希望可以在本地先預覽網站的模樣，等全部確定改好之後再一次 push 上去發布。

這篇文章就是要處理這個需求。過往許多 Jekyll 架站教學都從這裡寫起，但我覺得放在第三篇文章再提，讓一開始的架站成本降低，等需求自然出現後再來做進階的教學可能比較適合。所以，如果你是從第一篇一直跟到現在的，歡迎你繼續跟著我把 Jekyll 部署的最後一哩路走完。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">關於作業系統</span></div>
這篇文章主要會以 macOS 作為作業系統示範。Windows 的 Ruby 安裝方式完全不同，會使用到 RubyInstaller + DevKit，請參考 Jekyll 官方文件。不過除了本地環境安裝之外，其他部分是通用的。

</div>
## 本地環境需求

如果你照著第一篇的方法，使用 GitHub Actions 架設部落格，在這一步會少走很多彎路。

假如當初使用 `Deploy from a branch`，GitHub 會把 Jekyll 版本鎖在 `3.9.x`，可以用的 plugin 少很多。但本機裝的 Jekyll 版本都在 4.x 以上，會跟 GitHub 線上跑的不是同一套，容易產生本地跟真正部署看到的不同。而你照著第一篇用了 GitHub Actions，本機和線上跑的是同一個 Jekyll 版本，所以不會有這個問題。

既然現在沒有版本衝突問題，我們就可以來放心安裝 Ruby 設定環境了！

### 安裝 Ruby

Jekyll 是使用 Ruby 寫成的 SSG，因此要在本地跑 Jekyll 的話 Ruby 絕對不能少，第一步就要先安裝 Ruby。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">macOS 內建 Ruby</span></div>
千萬**不要使用** macOS 內建的 Ruby。這是 macOS 的系統檔案，版本老舊，而且需要用 `sudo` 強制越權安裝。Jekyll 官方明確要求使用版本管理器（如 chruby 或 rbenv），簡單方便又可以避免未來的系統問題。

</div>
要安裝 Ruby，請先確定 macOS 上已經有 `homebrew` 這個套件管理器（可以在終端機用 `brew -v` 測試），如果沒有的話可以先去[官網](https://brew.sh/)照著教學安裝。有了 `homebrew` 之後，我們就可以安裝 chruby 版本管理器以及 Ruby 本人：

```bash
brew install chruby ruby-install
ruby-install ruby 3.4            # <- 謹慎挑選版本號！
```

Ruby 的版本號請謹慎選擇，可以去看看目前使用的主題要求的最低版本號，選一個不要太新也不要太老的版本號安裝，現在我用的 3.4 與 Chirpy 主題的 CI 要求的版本對齊，不過每個人需要的版本會因為時間和更新有所不同。

接著要設定讓 shell 可以依照專案資料夾自動替換版本：

```bash
echo "source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh" >> ~/.zshrc
echo "source $(brew --prefix)/opt/chruby/share/chruby/auto.sh" >> ~/.zshrc
```

然後就可以在自己的 Jekyll repo 裡面固定 Ruby 的版本：

```bash
cd path/to/your/jekyll/site        # <- 填自己的 Jekyll repo
ruby -v
echo "ruby-3.4.x" > .ruby-version  # <- 按照上面的 ruby -v 照填，不要抄這裡的
```

### 安裝 Bundler 管理套件

有了 Ruby 之後就需要環境管理器 Bundler。如果有用過 python 虛擬環境的應該對這不陌生，Bundler 就是 Ruby 解決環境以及套件版本依賴的管理器，這可以避免電腦中有不同版本的 Ruby 套件（gem）而產生衝突：

```
gem install bundler
bundle install
```

這樣就差不多完成了，bundler 會幫你安裝這個部落格需要的所有套件，包含 Jekyll 本體。之後執行 Jekyll 都要加 `bundle exec` 前綴，這樣才會用到 `Gemfile` 裡指定的那個版本，而不是系統上隨便一個版本，確保部落格環境穩定一致。其實沒有想像中複雜，不過 Ruby 的安裝版本需要特別注意就好了。

## 在本地預覽部落格

Ruby 和 Jekyll 都安裝好後，在本地預覽部落格的方法只需要一行指令

```bash
bundle exec jekyll serve --livereload
```

現在你的部落格應該會出現在本機的 `http://localhost:4000` 上面了！而且只要部落格有任何改動（增加文章、修改 css）都會馬上刷新瀏覽器，即時反映。如果不加 `--livereload` 參數也可以，手動重新整理瀏覽器畫面就可以了，改動還是會即時同步。

<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">如果看到錯誤</span></div>
如果你的部落格用了比較舊的主題，有可能會看到 `cannot load such file -- webrick`。這是因為 Ruby 3.0 以後 `webrick` 被移出了標準函式庫。這時只要多打一串 `bundle add webrick` 再重新啟動伺服器就可以了。

</div>
### 一些在本機預覽的注意事項

#### `_config.yml` 如果改了要重啟伺服器

在 Jekyll 伺服器上，所有變動都會即時反應，就只有 `_config.yml` 的改動不會馬上反應。這份檔案是在伺服器開始時單次 load 進去的，所以如果改了 `_config.yml` 裡面的內容，請記得 Ctrl + C 關閉伺服器之後再重新用 `bundle exec jekyll serve --livereload` 重啟伺服器。

#### `baseurl` 在本機也會作用

如果你有在 `_config.yml` 中設定 `baseurl: "/blog"` 或其他 baseurl（也就是在 GitHub 上不是用 `username.github.io` 作為部落格 repo），請特別注意這個規則在本地也會適用。你的部落格會出現在 `localhost:4000/blog` 上，而單純的 `localhost:4000` 會是 404 Not Found。

<div class="callout callout-info" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="info"></i><span class="callout-title-text">順帶一提</span></div>
如果你有用第二篇的 Intaglio 而且設了 baseurl，本機預覽就是檢查連結有沒有重複加上 baseurl 的最快方式，不用等部署上線才發現。

</div>
#### 草稿和未來日期

如果在本地預覽時，想要看到草稿 `_drafts/` 資料夾以及發布日期設定在未來的文章的話，可以使用這個伺服器指令：

```bash
bundle exec jekyll serve --drafts --future
```

這樣就可以繞過日期限制以及草稿限制，看到所有稿子都發出去的樣子了。

#### 有些檔案不該 commit

有些不該 commit 的資料夾包含 `_site/`、`.jekyll-cache/`、`vendor/`、`.bundle/`。這些都會在每台機器（以及 GitHub 部署 CI 中）自行建立，不用 commit & push，以免造成衝突。

另外，如果你是用外面的主題，有些會把 `Gemfile.lock` 放進 `.gitignore`，這可避免跨平台的 lock 衝突，但有些主題不會。照你的主題設定的做就好。

#### 搭配 Intaglio 工作流（如果你有用）

如果你有使用第二篇文章提到的 Intaglio，就可以在 merge 完 PR 之後 `git pull` 你的部落格 repo 在本地直接看現成的版本，包含 callout 的轉換以及數學式。這樣就可以不用等二三十秒跑完部署再去線上看，本地就能檢查。

## 結語

整篇文章系列總算到了結尾。跟著這個文章系列走到現在，你應該已經搭建了一個穩定、簡單，又可以輕鬆發表文章的工作流了，也感受到自架部落格其實也沒那麼難。三篇加起來，可能會需要花上一個下午把所有設定跟環境調整好（架站半小時、Obsidian 自動化二十分鐘、設定本機環境以及等 Ruby 安裝約半小時），不過一完成之後就可以放著不管，去專心寫文章，剩下的就交給部落格自己跑。

Jekyll 其實還有很多好用的插件以及設定可以玩（如 permalink、文章 toc、分頁插件、RSS 等等），不過礙於篇幅限制以及每個人對部落格的想像和需求不同，我就不在這裡講了。有興趣的人歡迎去找更多網路資源，讓 Jekyll 變成展現自己專屬風格跟美學的地方。

{% include obsidian-callouts.html %}