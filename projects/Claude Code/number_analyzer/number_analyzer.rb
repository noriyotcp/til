# 数値配列の統計を計算するプログラム
arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# 合計を計算
sum = 0
arr.each do |val|
  sum = sum + val
end
puts "合計: #{sum}"

# 平均を計算
avg = sum / arr.length
puts "平均: #{avg}"

# 最大値を計算
max = arr[0]
arr.each do |val|
  if val > max
    max = val
  end
end
puts "最大値: #{max}"

# 最小値を計算
min = arr[0]
arr.each do |val|
  if val < min
    min = val
  end
end
puts "最小値: #{min}"