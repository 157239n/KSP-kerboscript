
// these are just hypotheses to help me understand kos's reference frame

heading(dir, pitch, roll).
r(pitch, yaw, roll).

ship:up + r(10, 0, 0) = heading(180, 80, 0) = heading(180, 90, 0) + r(10, 0, 0)
ship:up + r(-10, 0, 0) = heading(180, 100, 0) = heading(0, 80, 180)
= heading(180, 90, 0) + r(-10, 0, 0)




concrete rules:
r(a, b, c) + r(-a, -b, -c) = r(0, 0, 0)
r(a, b, c) - r(a, b, c) = r(0, 0, 0)
ship:up = heading(180, 90, 0)
heading(1, 2, 3) + r(0, 0, 0) - heading(1, 2, 3)

heading(1, 2, 3) + heading(-1, -2, -3) != r(0, 0, 0)



testing these:
heading(a, b, c) + r(d, 0, 0) = heading(a, b - d, c)
heading(1, 90, 3) + r(4, 0, 0) - heading(1, 90-4, 3)

