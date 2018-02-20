require 'discordrb'
require 'dotenv'
require 'tod'
require 'tod/core_extensions'

Dotenv.load
TOKEN = ENV["TOKEN"]
CLIENT_ID = ENV["CLIENT_ID"]

# 時差
TIME_DEFEERENCE = 9

# 秒単位での精度判定
class Decision
  PERFECT = 0
  GREAT = 10
  GOOD = 60
  BAD = 600

  def self.accuracy(delta)
    if delta <= Tod::TimeOfDay(Time.parse("1/1") + (PERFECT))
      return "PERFECT"
    elsif delta <= Tod::TimeOfDay(Time.parse("1/1") + (GREAT))
      return "GREAT"
    elsif delta <= Tod::TimeOfDay(Time.parse("1/1") + (GOOD))
      return "GOOD"
    elsif delta <= Tod::TimeOfDay(Time.parse("1/1") + (BAD))
      return "BAD"
    else
      return "POOR"
    end
  end
end



# Todで正午を出す
def TodNoon
  return Tod::TimeOfDay.parse("12:00")
end

# Todで真夜中を出す
def TodMidnight_0
  return Tod::TimeOfDay.parse("00:00")
end

def TodMidnight_24
  return Tod::TimeOfDay.parse("24:00")
end

bot = Discordrb::Bot.new token: TOKEN, client_id: CLIENT_ID
bot.message(containing: "ひるほー") do |event|
  hiruhoTime = Tod::TimeOfDay(event.timestamp + (60*60*TIME_DEFEERENCE))
  timeDelta = hiruhoTime > TodNoon() ? hiruhoTime - TodNoon() : TodNoon() - hiruhoTime
  judgment = Decision::accuracy(timeDelta)
  sign = hiruhoTime > TodNoon() ? '+' : '-'
  event.respond "#{judgment}\n#{sign}#{timeDelta}"
end
bot.message(containing: "よるほー") do |event|
  hiruhoTime = Tod::TimeOfDay(event.timestamp + (60*60*TIME_DEFEERENCE))
  timeDelta = hiruhoTime < TodNoon() ? hiruhoTime - TodMidnight_0() : TodMidnight_24() - hiruhoTime
  judgment = Decision::accuracy(timeDelta)
  sign = hiruhoTime > TodNoon() ? '-' : '+'
  event.respond "#{judgment}\n#{sign}#{timeDelta}"
end

bot.run
