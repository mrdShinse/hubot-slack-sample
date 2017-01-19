# Description:
#
# Commands:

Conversation = require('hubot-conversation')

class JenkinsCommand
  url  = ""
  user = ""
  token = ""
  repo = ""
  prof = ""

  generate: () ->
    "curl -X POST --user #{@user}:#{@token} #{@url}/buildWithParameters?svn_repository=#{@repo}&maven_profile=#{@prof}"

module.exports = (robot) ->
  conversation = new Conversation(robot)

  # コマンド本体
  robot.respond /jenkins/, (res) ->

    # 対話形式の有効時間（放置されるとタイムアウトする）
    dialog = conversation.startDialog res, 60000; # timeout = 1min
    dialog.timeout = (res) ->
      res.emote('タイムアウトです')

    # 対話形式スタート
    input_url res, dialog

  # 
  # 以下、対話式ダイアログです
  # 
  command = new JenkinsCommand

  # 入力値のトリムに使います
  trim_input = (str) ->str.trim()

  # 入力値の取得に使います
  get_input = (res) -> trim_input res.match[1]

  # URLの入力
  input_url = (res, dialog) ->
    res.send 'URLを教えてください。'
    dialog.addChoice /(.+)/, (res2) ->
      command.url = get_input res2
      input_login res2, dialog # 次に実行する関数をaddChoice内で呼びます

  input_login = (res, dialog) ->
    res.send ' ログインユーザーを教えてください。'
    dialog.addChoice /(.+)/, (res2) ->
      command.user = get_input res2
      input_token res2, dialog

  input_token = (res, dialog) ->
    res.send 'トークンを教えてください。'
    dialog.addChoice /(.+)/, (res2) ->
      command.token = get_input res2
      input_repository res2, dialog

  input_repository = (res, dialog) ->
    res.send 'ビルドするリポジトリを教えてください。'
    dialog.addChoice /(.+)/, (res2) ->
      command.repo = get_input res2
      input_profile res2, dialog

  input_profile = (res, dialog) ->
    res.send 'プロファイル名を教えてください。'
    dialog.addChoice /(.+)/, (res2) ->
      command.prof = get_input res2
      show_result res2, dialog

  # 結果表示
  show_result = (res, dialog) ->
    res.send "結果です\n#{command.generate()}"
