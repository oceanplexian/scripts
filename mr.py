a = [1, 2, 3]
b = [4, 5, 6, 7]
c = [8, 9, 1, 2, 3]
L = map(lambda x:len(x), [a, b, c])

# L == [3, 4, 5]
N = reduce(lambda x, y: x+y, L)



print N;
