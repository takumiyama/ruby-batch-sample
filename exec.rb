require './controller.rb'

# 実行されたらmainを呼び出す
if __FILE__ == $0
  controller = Main.new
  controller.main
end