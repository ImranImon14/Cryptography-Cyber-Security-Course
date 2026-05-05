def ImranGCD(a, b):
    x1, y1 = 1, 0
    x2, y2 = 0, 1

    while b != 0:
        q = a // b
        r = a % b

        a, b = b, r

        x = x1 - q * x2
        y = y1 - q * y2

        x1, y1 = x2, y2
        x2, y2 = x, y

    return a, x1, y1


# Input
a = int(input())
b = int(input())

# Function call
gcd, x, y = ImranGCD(a, b)

# Output
print("GCD is:", gcd)
print("Coefficients are: x =", x, ", y =", y)