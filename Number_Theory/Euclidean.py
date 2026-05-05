def ImranGCD(r1, r2):
    while r2 != 0:
        r1, r2 = r2, r1 % r2
    return r1

num1 = int(input("Enter first number: "))
num2 = int(input("Enter second number: "))

result = ImranGCD(num1, num2)

print("GCD is:", result)