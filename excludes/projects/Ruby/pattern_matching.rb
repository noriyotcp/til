# https://x.com/lucianghinda/status/1797834091959558241
Result = Data.define(:code, :payload)

# def perform
#   return Result.new(code: :ok, payload: "This works")
# end

def perform
  return Result.new(code: :error, payload: "This does not works")
end

case perform
in [:ok, summary]
  puts summary
in [:error, error_message]
  puts error_message
end

