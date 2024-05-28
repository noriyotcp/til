# Ruby 3.4, Block passing as an argument is no longer allowed in index and it throws SyntaxError.

numbers = []

even_block = Proc.new { |i| i.even? }

def numbers.[]=(*args, &block)
  self.concat(args.flatten)
end

numbers[&even_block] = 10

p numbers #=> [10]

numbers[&even_block] = 11, 12

p numbers #=> [10, 11, 12]

# after 3.4
# ruby-3-4-throws-syntax-error-for-passing-block-in-index.rb:
# ruby-3-4-throws-syntax-error-for-passing-block-in-index.rb:11: block arg given in index (SyntaxError)
# numbers[&even_block] = 10
#          ^~~~~~~~~~
# ruby-3-4-throws-syntax-error-for-passing-block-in-index.rb:24: block arg given in index
# numbers[&even_block] = 11, 12
#         ^~~~~~~~~~

