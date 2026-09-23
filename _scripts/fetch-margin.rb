# frozen_string_literal: true

# Pull memos tagged #margin from Memos into the `margin` collection.
#
#   MEMOS_TOKEN=... ruby _scripts/fetch-margin.rb
#
# Runs before `jekyll build` (see .github/workflows/build-and-deploy.yml).
# _margin/ and assets/margin/ are generated: wiped and rewritten every run,
# so removing the tag in Memos unpublishes the entry on the next build.
# Written against Memos 0.25.x (API v1).

require "fileutils"
require "json"
require "net/http"
require "time"
require "uri"
require "yaml"

BASE = ENV.fetch("MEMOS_URL", "https://memos.kckhchen.com").chomp("/")
TOKEN = ENV["MEMOS_TOKEN"].to_s
TAG = ENV.fetch("MEMOS_TAG", "margin")

ROOT = File.expand_path("..", __dir__)
POSTS_DIR = File.join(ROOT, "_margin")
ASSETS_DIR = File.join(ROOT, "assets", "margin")

# Memos' own tag syntax: `#` followed by anything up to whitespace.
# Matches #margin and #margin/sub, but not #marginal.
PUBLISH_TAG = %r{(?<=\A|\s)##{Regexp.escape(TAG)}(?:/\S*)?(?=\s|\z)}

def get(path, query = {})
  uri = URI("#{BASE}#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  req = Net::HTTP::Get.new(uri)
  req["Authorization"] = "Bearer #{TOKEN}"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(req) }
  abort "GET #{uri.path} -> #{res.code}: #{res.body.to_s[0, 200]}" unless res.is_a?(Net::HTTPSuccess)
  res.body
end

def get_json(path, query = {})
  JSON.parse(get(path, query))
end

def list_memos
  memos = []
  token = ""
  loop do
    page = get_json("/api/v1/memos", {
      filter: %(tag in ["#{TAG}"]),
      orderBy: "display_time desc",
      pageSize: 100,
      pageToken: token
    })
    memos.concat(page.fetch("memos", []))
    token = page["nextPageToken"].to_s
    break if token.empty?
  end
  memos
end

# The filename becomes the URL, so keep it to something that survives a path.
def safe_filename(name)
  name.gsub(/[^\w.\-]+/, "-").sub(/\A[.\-]+/, "")
end

def download_attachments(memo, id)
  memo.fetch("attachments", []).map do |att|
    if att["externalLink"].to_s != ""
      { "url" => att["externalLink"], "filename" => att["filename"], "type" => att["type"] }
    else
      filename = safe_filename(att["filename"])
      dir = File.join(ASSETS_DIR, id)
      FileUtils.mkdir_p(dir)
      File.binwrite(File.join(dir, filename), get("/file/#{att['name']}/#{URI.encode_uri_component(att['filename'])}"))
      { "path" => "/assets/margin/#{id}/#{filename}", "filename" => att["filename"], "type" => att["type"] }
    end
  end
end

def title_for(content, time)
  line = content.lines.map(&:strip).find { |l| !l.empty? }.to_s
  line = line.sub(/\A#+\s+/, "").gsub(/[*_`>\[\]]/, "")
  line = time.strftime("%Y-%m-%d") if line.empty?
  line.length > 40 ? "#{line[0, 40]}…" : line
end

def write_entry(memo)
  id = memo.fetch("name").split("/").last
  time = Time.parse(memo["displayTime"] || memo.fetch("createTime")).getlocal("+08:00")
  content = memo.fetch("content").gsub(PUBLISH_TAG, "").gsub(/[ \t]+$/, "").gsub(/^ (?=\S)/, "").strip
  tags = memo.fetch("tags", []).reject { |t| t == TAG || t.start_with?("#{TAG}/") }

  front = {
    "title" => title_for(content, time),
    "date" => time.strftime("%Y-%m-%d %H:%M:%S %z"),
    "last_modified_at" => Time.parse(memo.fetch("updateTime")).getlocal("+08:00").strftime("%Y-%m-%d %H:%M:%S %z"),
    "memo" => memo["name"],
    "tags" => tags,
    "attachments" => download_attachments(memo, id)
  }

  # Memo text is not a Liquid template: `{{ }}` in a code sample must stay literal.
  # Not {% raw %}: Jekyll 3's excerpt scanner still sees `{% if` inside it and
  # "closes" it. Instead every `{` that would open a tag is emitted by Liquid itself.
  body = content.gsub(/\{(?=[{%])/, "{{ '{' }}")
  File.write(File.join(POSTS_DIR, "#{id}.md"), "#{front.to_yaml}---\n\n#{body}\n")
end

FileUtils.rm_rf([POSTS_DIR, ASSETS_DIR])
FileUtils.mkdir_p(POSTS_DIR)

if TOKEN.empty?
  warn "MEMOS_TOKEN not set; building without margin entries."
  exit
end

me = get_json("/api/v1/auth/sessions/current").dig("user", "name")
# An authenticated list also includes other users' PUBLIC/PROTECTED memos.
memos = list_memos.select { |m| m["creator"] == me }
memos.each { |m| write_entry(m) }
puts "margin: #{memos.size} entries from #{BASE}"
