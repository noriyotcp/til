# https://allaboutcoding.ghinda.com/endless-method-a-quick-intro
#
def valid?(value) = if value.start_with?("ShortRuby")
  true
else
  false
end

p valid?("ShortRubyDesu")

class Assignee
  def initialize(org, permission)
    @org = org
    @permission = permission
  end
end

# def assignee(organisation, permission:) = case permission[:role]
#   when "admin" then Assignee.new(organisation, "admin")
#   when "member" then Assignee.new(organisation, "member")
#   else Assignee.new(organisation, "guest")
# end
# 
# def assignee(organisation, permission:) = case permission[:role]
# when "admin"
#   Assignee.new(organisation, "admin")
# when "member"
#   Assignee.new(organisation, "member")
# else
#   Assignee.new(organisation, "guest")
# end

def assignee(org, permission:) = case permission[:role]
                                 when "admin"
                                   Assignee.new(org, "admin")
                                 when "member"
                                   Assignee.new(org, "member")
                                 else
                                   Assignee.new(org, "guest")
                                 end


p assignee("GitHub", permission: { role: 'guest' })

class ::Twitter; end

# class ::Twitter::Client
#   def me
#     get "/users/me"
#   end
# 
#   def tweets(tweet_ids:)
#     get "/tweets?ids=#{tweet_ids.join(',')}"
#   end
# 
#   def post_tweets(tweet_ids:)
#     post "/tweets?ids=#{tweet_ids.join(',')}", body: { tweet: "This is the tweet" }, headers: { Host: "x.com" }
#   end
# 
#   private
# 
#     def get(path)
#       request(:get, path)
#     end
# 
#     def post(path, body: {}, headers: {})
#       request(:post, path, body:, headers:)
#     end
# 
#     def request(method, path, body: {}, headers: {})
#       "#{method} #{path} #{body} #{headers}"
#     end
# end

class ::Twitter::Client
  def me = get "/users/me"

  def tweets(tweet_ids:) = get "/tweets?ids=#{tweet_ids.join(',')}"

  def post_tweets(tweet_ids:) = post "/tweets?ids=#{tweet_ids.join(',')}", body: { tweet: "This is the tweet" }, headers: { Host: "x.com" }

  private

    def get(path) = request(:get, path)

    def post(path, body: {}, headers: {}) = request(:post, path, body:, headers:)

    def request(method, path, body: {}, headers: {}) = "#{method} #{path} #{body} #{headers}"
end


p ::Twitter::Client.new.me
p ::Twitter::Client.new.tweets(tweet_ids: [1, 2, 3])
p ::Twitter::Client.new.post_tweets(tweet_ids: [1, 2, 3])

