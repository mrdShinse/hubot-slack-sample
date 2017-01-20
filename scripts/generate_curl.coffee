# Description:
#   helps you to make curl command.
#
# Commands:
#   hubot teach curl - building curl command in coversation with bot.

Conversation = require('hubot-conversation');

class CurlCommand
  url = ""
  width = 0
  height = 0
  device = ""
  timezon = ""

  generate: () ->
    "curl #{@url}?width=#{@width}&height=#{@height}&device=#{@device}&timezone=#{@timezone}"

module.exports = (robot) ->
  conversation = new Conversation(robot)

  # コマンド本体
  robot.respond /teach\scurl/, (res) ->

    # 対話形式の有効時間（放置されるとタイムアウトする）
    dialog = conversation.startDialog res, 60000; # timeout = 1min
    dialog.timeout = (res) ->
      res.emote('タイムアウトです')

    # 対話形式スタート
    input_url res, dialog

  # 
  # 以下、対話式ダイアログです
  # 
  p = new CurlCommand

  # 入力値のトリムに使います
  trim_input = (str) ->str.trim()

  # URLの入力
  input_url = (res, dialog) ->
    res.send 'URLを教えて下さい [ 例) http://sample.com/api/sample ]'
    dialog.addChoice /(.+)/, (res2) ->
      p.url = trim_input res2.match[1]
      input_width res2, dialog # 次に実行する関数をaddChoice内で呼びます

  # 幅パラメータの入力
  input_width = (res, dialog) ->
    res.send '横幅を教えて下さい [ 数字を入力 ]'
    dialog.addChoice /(.+)/, (res2) ->
      p.width = trim_input res2.match[1]
      input_height res2, dialog

  # 高さパラメータの入力
  input_height = (res, dialog) ->
    res.send '縦幅を教えて下さい [ 数字を入力 ]'
    dialog.addChoice /(.+)/, (res2) ->
      p.height = trim_input res2.match[1]
      input_device res2, dialog

  # デバイスパラメータの入力 
  input_device = (res, dialog) ->
    res.send 'デバイスを教えて下さい [ "pc", "sp", "ios", "android" いずれかを入力]'
    dialog.addChoice /(.+)/, (res2) ->
      # ここにバリデーションをいれるのも可能です
      p.device = trim_input res2.match[1] 
      input_timezone res2, dialog

  # タイムゾーンパラメータの入力
  input_timezone = (res, dialog) ->
    # 数字で入力させることで、些細なスペルミスを予防しています
    res.send 'タイムゾーンを教えて下さい [ 1=Asia/Tokyo, 2=America/Chicago 数字を入力]'
    dialog.addChoice /1/, (res2) ->
      p.timezone = "Asia/Tokyo"
      show_result res2, dialog
    dialog.addChoice /2/, (res2) ->
      p.timezone = "America/Chicago"
      show_result res2, dialog

  # 結果表示
  show_result = (res, dialog) ->
    res.send "結果です\n`#{p.generate()}`"
