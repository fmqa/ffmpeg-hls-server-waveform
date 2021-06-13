from setuptools import find_packages, setup

setup(
    name="hlsserver",
    version="1.0.0",
    description="HLS Radio Server",
    platforms=["POSIX"],
    packages=find_packages(),
    include_package_data=True,
    install_requires=["aiohttp>=3.7,<3.8", "fastjsonschema"]
)