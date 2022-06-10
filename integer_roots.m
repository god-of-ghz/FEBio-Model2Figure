function [result] = integer_roots(num)
% helper function to determine integer "roots" for a number (basically to make and X * Y square of a set of images

square1 = round(sqrt(num));

while (mod(num, square1) ~= 0)
    square1 = square1 + 1;
end
assert(mod(num,square1) == 0);
square2 = num/square1;

result = [square2 square1];