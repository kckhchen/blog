---
date: 2026-02-01
generator: intaglio
layout: post
share: true
tags:
- ruby
- python
title: Ruby 和 Python 的 yield 指令
---

在學習 Ruby 和 Python 一段時間後，兩門語言終究會讓你碰到一個神秘的關鍵字：`yield`。曾經這個關鍵字困擾了我一段時間，因為他們的用法這麼的相似，卻同時這麼的不同，乍看之下似乎可以將經驗直接套用，但實際操作時卻往往造成意想不到的錯誤。在經過多方閱讀和整理後，我才想寫一篇文章分享這個神奇的指令。

在 Ruby 和 Python 中，`yield` 指令都是非常常見且關鍵的指令，並且都有「暫停函式運行」與「讓步給其他函式」的特性。但雖然名字平平都是 `yield`，Ruby 和 Python 卻有非常不同的使用情境。這篇文章將會分別介紹其中的相似性以及差異。

## Ruby 中的 yield

Ruby 的 `yield` 可以說是 Ruby 最核心的功能之一，幾乎所有入門課程都會學到。Ruby 的 `yield` 用處在於「暫停目前函式，並運行**傳進來的 block**」。直接用例子解釋最清楚：

```ruby
def calc(num1, num2)
  puts "Starts calculation..."
  yield num1, num2
  puts "Calculation finished!"
end

calc(1, 2) { |a, b| puts a + b }
```
{: #secid768e7d}

在上面的範例中 `calc` 函數接受三個引數：兩個數字和一個 callback block。這個函數只做一件事情：宣告計算的開始和結束。至於怎麼計算將會交給它 `yield` 的 block，並且將前兩個引數也一起傳送過去。

因此，這個程式的運行結果會是：

```
Starts calculation...
3
Calculation finished!
```

我們也可以改送入別的 block：

```rb
calc(5, 3) { |a, b| puts a - b }
```

得到的結果就會是：

```
Starts calculation...
2
Calculation finished!
```

因此，中間那行印出什麼數字跟 `calc` 函數本身沒有關係，這個函數看到 `yield` 時只會停下目前的函式運行，「讓路」給傳送進來的 block。等到那個 block 執行完，`calc` 才會繼續把剩下的部分運行完成。

`yield` 也接受 lambda 作為傳入的 block：
```rb
multiply = ->(a, b) { puts a * b }
calc(3, 4, &multiply)

# returns:
# Starts calculation...
# 12
# Calculation finished!
```


<div class="callout callout-warning" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="circle-alert"></i><span class="callout-title-text">注意</span></div>
`yield` 僅接受 block 作為傳入值，因此當使用 lambda 時，不能直接傳入 `calc(3, 4, multiply)`，必須使用 `&` 將 lambda 物件中的 block 取出。


</div>
因此，有 `yield` 的函式的工作流程大概像這樣：

> 接受參數 → 執行程式 → 暫停程式，將參數（如果有）傳給 callback → 等待 callback 執行 → 繼續執行剩下程式

### Ruby yield 的更多功用

Ruby 的 `yield` 的好處不只在於它巨大的彈性，也在於 `yield` 可以重複多次使用。我們可以來看下面這個範例：

```rb
def say_n_times(n)
  n.times do
    yield
  end
end

say_n_times(3) { puts "This is important." }

# returns:
# This is important.
# This is important.
# This is important.
```

函數每 `yield` 一次，就會運行送進來的 block 一次。

另外，Ruby 也內建了 `#block_given?` 方法讓我們可以依據有沒有 block 傳入決定函式運行規則：

```rb
def check_block
  if block_given?
    msg = yield # 接收 block 的回傳值
    puts "Block says #{msg}."
  else
    puts "No block given."
  end
end

check_block { "hi" }
#=> Block says hi.

check_block
#=> No block given.
```


<div class="callout callout-note" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="pen"></i><span class="callout-title-text">注意</span></div>
上方所有函式都不需要特別加入 `&block` 作為引數，因為所有 Ruby 函式都預設可以接受一個 block 作為額外參數。如果對這部分有更多興趣，這篇很有啟發性的 [Medium 文章](https://medium.com/@jinghua.shih/ruby-%E5%A6%82%E4%BD%95%E7%90%86%E8%A7%A3-ruby-block-2387b74f188b) 推薦給你！

</div>

## Python 中的 yield

雖然名字都是 `yield`，Python 對於 `yield` 卻有完全不同的見解和使用方式。在 Python 中，只要 `yield` 出現在函式裡面，就會將該函式變成一個生成器（generator）。碰到 `yield` 時，生成器函式會暫停執行，回傳一個值給主函式，並且**等待下一次函式呼叫**。

Python 中的 `yield` 最大的用處在於 iterator 當中：

```python
def printer():
    for i in _iterator():
        print(i)

def _iterator():
    yield 1
    yield 2
    yield 3
```

這時如果我們呼叫 `printer()`，會得到以下結果：

```
1
2
3
```

也就是說，`printer` 在第一圈 loop 時，會先呼叫 `_iterator`，這時 `_iterator` 會**回傳 1，並且暫停執行**，等到 `printer` 印完，進入第二圈 loop 再次呼叫時，才會繼續執行，回傳 2 後再暫停，直到程式完全執行完畢或是不再被呼叫為止。

### Python yield 的好處

這時許多人可能會有一個疑問：如果我要使用 loop，為什麼不直接 iterate over 一個 list 就好，要這麼麻煩使用一個有 `yield` 的函式呢？

主要是因為函式在加上 `yield` 之後，就不再是一般的函式，而會變成生成器。生成器在回傳一值之後，就會馬上「忘記」，不會將值儲存在記憶體中（也就是 lazy loading），這對於非常大筆的數據或是很佔空間的檔案非常有利，因為這可以讓我們節省非常多記憶體空間。

舉個例子，如果我想要將我寫的所有部落格文章進行文字處理，我就可以運用生成器：

```python
def save_post(src_paths):
    # src_path is a list of paths
    for content in _iter_posts(src_paths):
        processed = process_post(content)
        # ... goes on to save posts

def _iter_posts(paths):
    for src in paths:
        with open(src, "r") as f:
            content = f.read()
            yield content
```

`_iter_posts` 每次只會打開一個檔案，讀取裡面的文字內容，並傳回主函式 `save_post`。等到主函式處理完這個文章後，在下一次迴圈再次向 `_iter_post` 索取下一個值，`_iter_post` 就會**關掉並且忘記上一個檔案**，讀取下一個路徑的檔案，並回傳下個檔案的文字內容。也就是說，整個程式碼在運行的期間，同時只會有一個檔案的文字內容存在記憶體中。如果我們使用 list 儲存的話，那就必須先把所有文章內容同時存在記憶體中，讓函式一個一個讀取，造成記憶體壓力，也造成不必要的空間浪費。

### 更進一步：yield from

Python 除了 `yield` 之外，更進一步提供了 `yield from` 的功能，讓我們可以從**另一個生成器讀取值**，並回傳到主函式，有點像是接力傳球的概念：

```python
def printer():
    for i in _iterator():
        print(i)

def _iterator():
    yield from [1, 3, 5]
	
# 上面的方法等價於
# for x in [1, 3, 5]:
#     yield x

printer()

# returns:
# 1
# 3
# 5
```
{: #secid773608}

這裡的 `_iterator` 在被呼叫時，會轉而向另一個生成器（也就是 Python 內建給 list `[1, 3, 5]` 的生成器）求值，並把值回傳給主函式 `printer`。雖然在這個範例中這個用法看起來像是多此一舉，不過在更複雜的使用情境中意外地非常好用。


## 合併比較

最後我們重新把 Ruby 和 Python 使用 `yield` 的情境整理和比較一次：

- Ruby 的 `yield` 存在於主函式中，會**暫停主函式，讓子函式（block）運行**，結束後繼續執行主函式。
- Python 的 `yield` 存在子函式中，會**暫停子函式（generator），回傳值給主函式**，並且直到下次被呼叫才會繼續運行。

我們也可以把兩個語言的 `yield` 化約成「主動」和「被動」的概念。

- Ruby 的 `yield` 是主動的：主函式 `yield` 傳進來的 block 執行動作，主函式 `yield` 幾次，block 就要運行幾次。主控權在有 `yield` 的主函式身上。
- Python 的 `yield` 是被動的：只要被呼叫，生成器就會 `yield` 一個回傳值，但只要不（再）被呼叫，`yield` 就不會動作。主控權在呼叫生成器的函式身上。

### 腦力激盪：用 Python `yield` 寫 Ruby 邏輯

回到一開始我們為 Ruby 寫的[範例程式](#secid768e7d)：

```ruby
def calc(num1, num2)
  puts "Starts calculation..."
  yield num1, num2
  puts "Calculation finished!"
end

calc(1, 2) { |a, b| puts a + b }
```

我們能不能用 Python 的 `yield` 寫出這樣的邏輯？答案是可以，我們可以讓加法變成主函式，並讓 `calc` 成為被呼叫的子函式：

```python
def calc(num1, num2):
    print("Starts calculation...")
    yield num1, num2
    print("Calculation finished!")


def add(num1, num2):
    for num1, num2 in calc(num1, num2):
        print(num1 + num2)

add(1, 2)
```

這時的程式碼工作流程長什麼樣子呢？

> `add(1, 2)` 被呼叫 → 在迴圈呼叫 `calc(1, 2)` → `calc` 印出 "Starts calculation..." 並回傳 1, 2 後暫停運作 → `add` 印出加法結果，進入下一個迴圈 → `calc` 再次被呼叫，繼續執行，印出 "Calculation finished!" 後枯竭（沒有其他東西可以 yield 了）→ `add` 得知 `calc` 枯竭，跳出迴圈結束執行。

非常複雜吧！不過重點不是中間到底發生了什麼事，這裡舉例只是為了更清楚說明 `yield` 在 Python 中更像是屬於子函式的功能而已。

<div class="callout callout-error" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="zap"></i><span class="callout-title-text">警告</span></div>
以上的程式碼僅供示例和比較用途，這並非 Python 的 `yield` 的設計邏輯，強硬逼迫 Python 這樣運作只會讓程式碼變得非常難讀。另外，其實 Python 有提供 `@contextmanager` 裝飾子讓整個函式更簡潔、更像 Ruby，不過已經超出本次討論範圍。

</div>
### 腦力激盪：用 Ruby yield 寫 Python 邏輯

反過來說，能不能用 Ruby 的 yield 寫出上面的[這個 Python 邏輯](#secid773608)？

```python
def printer():
    for i in _iterator():
        print(i)

def _iterator():
    yield from [1, 3, 5]
```

當然也可以，只要抓住核心重點，讓主函式 `printer` yield 給子函數（block）就可以了：

```rb
def printer(list)
  list.each { |item| yield item }
end

printer([1, 3, 5]) { |i|  puts i }
```

這裡的程式工作流程變成以下：

> `printer([1, 2, 3])` 被呼叫 → 透過 `#each` 方法每次 yield 一個值給 `{ puts i }` 的 block → block 執行完畢，控制權交還給 `printer` → 進入下一次迴圈 → ... → list 枯竭，程式結束

<div class="callout callout-error" markdown="1"><div class="callout-title"><i class="callout-icon" data-lucide="zap"></i><span class="callout-title-text">警告</span></div>
這在 Ruby 中一樣是很不直覺且曲折的寫法，僅供展示比較。而且 `#each` 方法已經內建使用 `yield` 了（有沒有發現 `#each` 的使用方式也是傳入一個 block？）。另外，如果想在 Ruby 中實現 lazy loading，必須額外調用 `#lazy` 方法（Ruby 2.0+）或是使用 `Enumerator`，但這不在本次的討論範圍內。

</div>
## 結論

這篇文章還有更多的相似性和差異沒有講到，不過為了不模糊文章焦點，就先略過了。

繞了一大圈，希望沒有讓大家暈頭轉向。這篇文章比較適合熟悉其中一門語言，想透過邏輯類比學習另一門語言的人閱讀。就算平常沒有太多使用到 `yield` 的場景，希望這篇文章也可以給你一點啟發，或是至少在腦力激盪的環節玩得開心！

{% include obsidian-callouts.html %}