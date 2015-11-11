class DashboardController < ApplicationController
  def index
    Restaurant.connection.execute "select setseed(#{seed})"
    @restaurants = Restaurant.order 'random()'
    @comments = Comment.where("created_at >= ?", Time.zone.now.beginning_of_day)
    @comment = Comment.new
    @top_5 = top_for_date Date.today
    @last_3_days = last_3_days
  end

  private

  def seed
    today = Date.today + 1
    Random.new(today.day * today.month * today.year).rand - 1
  end

  def top_for_date(date, top = 5)
    ActiveRecord::Base.connection.exec_query("
      SELECT restaurants.name, COUNT(votes) as res_votes
      FROM restaurants
      LEFT JOIN votes as votes ON votes.restaurant_id = restaurants.id
      WHERE votes.date = '#{date}'
      GROUP BY restaurants.id
      ORDER BY res_votes DESC
      LIMIT #{top}").rows
  end

  def last_3_days
    top = []
    stop = Date.today
    start = stop - 3
    for date in start...stop
      top << {date: date, restaurant: top_for_date(date, 1).first.try(:first)}
    end
    top.reverse
  end
end
