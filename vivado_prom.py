import sys, subprocess, os

base = sys.argv[1]
major, minor, feature, build = [int(x) for x in sys.argv[2:6]]

sha = subprocess.getoutput("git -C ../.. rev-parse --verify HEAD")
dirty = bool(subprocess.getoutput("git -C ../.. status --porcelain"))

filename = "%s_%02x.%02x.%02x.XX-%s%s.bin"  %(base, major, minor, feature, sha[:10], "-dirty" if dirty else "")

while True:
    if build > 255:
        raise Exception("Cannot create more than 255 builds. Increment the version number")
    fname = "rev/"+filename.replace("XX", "%02x" % build)
    if os.path.exists(fname):
        build +=1
    else:
        break

if sys.argv[6] == "filename":
    print(fname)
else:
    print(build)
    
