#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'flowdock'
require 'json'

env = File.open("./.env") { |f| YAML.load(f) }

today = Time.now.strftime("%w")
quit 0 if [0,6].include?(today.to_i)
blancco = Nokogiri::HTML(open("http://www.ravintolablancco.com")).css(".lounas > div > h3")

begin
        dylan = open("https://www.facebook.com/feeds/page.php?id=171106726298873&format=json", {'User-Agent' => 'Mozilla'}) do |f|
                JSON.parse(f.read.to_s)["entries"][0]["content"]
        end
        lunchmenu = open("https://www.facebook.com/feeds/page.php?id=471456039557816&format=json", {'User-Agent' => 'Mozilla'}) do |f|
                JSON.parse(f.read.to_s)["entries"][0]["content"]
        end

rescue OpenURI::HTTPError => ex
        dylan = "Facebook bork'n"
end

lunchmenu = "<h1>West Beverly</h1> " +
                lunchmenu.to_s +
                "<br><br> <h1>Blancco</h1>" +
                blancco.to_s +
                "<br><br><h1>Dylan Pink</h1><p>" + dylan + "</p>" +
                "<br><br> <h1>Kilim</h1> KEBAB"

Flowdock::FLOWDOCK_API_URL = env["flowdock_endpoint"] if env["flowdock_endpoint"]

flow = Flowdock::Flow.new(
  :api_token => env["flowdock_api_token"],
  :source => "Lounasmaatti",
  :from => {
    :name => "Lolnaat",
    :address => env["from_address"]
  },
  :external_user_name => "Lounasmaatti"
)

# send message to the flow
flow.push_to_team_inbox(:subject => "Lounas tänään",
                  :link => "http://www.ravintola-macondo.com/",
                  :content => lunchmenu.to_s,
                  :tags => ["lolnaat"])


# Randomly post something to chat to draw attention
sleep 4
comments = ["aikamoiset lolnaat", "huhhuh, onneks ei oo happokalaa", "taitaa olla kaljapäivä!", "taitaa olla burgeripäivä", "oisko nepal?", "LOUNAS!", "omnomnomnom tofuburgerii", "toivottavasti o rokkikokki, muuten syön pelkkää kaljaa!"]
flow.push_to_chat(:content => comments[rand(comments.length)], :tags => "")



