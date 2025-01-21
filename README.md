# demo-v1cs

git clone https://github.com/andrefernandes86/demo-v1cs.git

cd demo-v1cs

docker buildx create --use

for amd64: docker buildx build --platform linux/amd64 -t demo-v1cs --load .

or for arm64: docker buildx build --platform linux/arm64 -t demo-v1cs --load .

docker run -it demo-v1cs bash
