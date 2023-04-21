GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

git pull
if [ $? -eq 0 ]; then
    echo -e "${GREEN}-----Git pull succeeded-----${NC}"
else
    echo -e "${RED}-----Git pull failed-----${NC}"
    exit 1
fi

mkdir build
cd build
cmake ..
if [ $? -eq 0 ]; then
    echo -e "${GREEN}-----Cmake succeeded-----${NC}"
else
    echo -e "${RED}-----Cmake failed-----${NC}"
    exit 1
fi

make
if [ $? -eq 0 ]; then
    echo -e "${GREEN}-----Make succeeded-----${NC}"
else
    echo -e "${RED}-----Make failed-----${NC}"
    exit 1
fi

./my_tests
if [ $? -eq 0 ]; then
    echo -e "${GREEN}-----My tests succeeded-----${NC}"
else
    echo -e "${RED}-----My tests failed-----${NC}"
    exit 1
fi

cd ..
rm -rf build