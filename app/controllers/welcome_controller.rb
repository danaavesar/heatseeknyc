class WelcomeController < ApplicationController

  require "will_paginate/array"

  def index
    allow_nginx_page_caching
    # redirect_to current_user if current_user
    # render "current_user_index" if current_user
  end

  def judges_welcome
    allow_nginx_page_caching
    @judges = User.judges
  end

  def press
    allow_nginx_page_caching
    @articles = Article.order(created_at: :desc).all
  end

  def blog
    allow_nginx_page_caching
    page_size = 4
    page = params[:page] ? params[:page].to_i : 1

    client = Tumblr::Client.new({
      :consumer_key => ENV['TUMBLR_CONSUMER_KEY'],
      :consumer_secret => ENV['TUMBLR_CONSUMER_SECRET'],
      :oauth_token => ENV['TUMBLR_OAUTH_TOKEN'],
      :oauth_token_secret => ENV['TUMBLR_OAUTH_TOKEN_SECRET']
    })

    result = client.posts(
      'heatseeknyc.tumblr.com',
      :limit => page_size,
      :offset => page_size * (page - 1)
    )

    total_pages = result["total_posts"].fdiv(page_size).ceil
    render 'public/404' if page > total_pages

    @entries = result['posts'].sort{|a,b| b['date'] <=> a['date']}
    @entries.define_singleton_method(:total_pages){total_pages}
    @entries.define_singleton_method(:current_page){page}
  end


  def thankyou
    allow_nginx_page_caching
    render 'thankyou'
  end

  private

  def allow_nginx_page_caching # for nginx and great justice, I mean speed.
    unless Rails.env.test? || Rails.env.development?
      expires_in(5.minutes, :public => true)
    end
  end
end

