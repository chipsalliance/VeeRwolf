import sys

with open(sys.argv[1], "rb") as f:
    data = f.read(4)
    while data:
        w2 = "{:02X}{:02X}{:02X}{:02X}".format(data[3],
                                               data[2],
                                               data[1],
                                               data[0])
        try:
            data = f.read(4)
            w1 = "{:02X}{:02X}{:02X}{:02X}".format(data[3],
                                                   data[2],
                                                   data[1],
                                                   data[0])
        except:
            w1 = "00000000"
        print("{}{}".format(w1,w2))
        data = f.read(4)
