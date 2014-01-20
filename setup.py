from setuptools import setup, find_packages
from Cython.Build import cythonize


setup(
    name='smoke',
    version='1.0',
    description='Fast, full Dota 2 game replay parser.',
    long_description=open('README.md').read(),
    author='Joshua Morris',
    author_email='onethirtyfive@skadistats.com',
    zip_safe=True,
    url='https://github.com/skadistats/smoke',
    license='MIT',
    packages=find_packages(),
    keywords='dota replay parser',
    install_requires=[
        'palm==0.1.9',
        'python-snappy==0.5',
        'cython>=0.19.1'
    ],
    classifiers=[
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries :: Python Modules',
        "Programming Language :: Python :: 2.7",
        "Topic :: Database"
    ],
    ext_modules=cythonize([
        "smoke/io/factory.pyx",
        "smoke/io/plexer.pyx",
        "smoke/io/util.pyx",
        "smoke/io/wrap/demo.pyx",
        "smoke/io/wrap/embed.pyx",
        "smoke/io/stream/generic.pyx",
        "smoke/io/stream/entity.pyx",
        "smoke/model/collection/entities.pyx",
        "smoke/model/collection/game_event_descriptors.pyx",
        "smoke/model/collection/recv_tables.pyx",
        "smoke/model/collection/string_tables.pyx",
        "smoke/model/dt/recv_table.pyx",
        "smoke/model/dt/send_table.pyx",
        "smoke/model/string_table.pyx",
        "smoke/replay/decoder/dt.pyx",
        "smoke/replay/decoder/packet_entities.pyx",
        "smoke/replay/decoder/recv_prop/darray.pyx",
        "smoke/replay/decoder/recv_prop/dfloat.pyx",
        "smoke/replay/decoder/recv_prop/dint.pyx",
        "smoke/replay/decoder/recv_prop/dint64.pyx",
        "smoke/replay/decoder/recv_prop/dstring.pyx",
        "smoke/replay/decoder/recv_prop/dvector.pyx",
        "smoke/replay/decoder/recv_prop/dvectorxy.pyx",
        "smoke/replay/decoder/string_table.pyx",
        "smoke/replay/demo.pyx",
        "smoke/replay/handler.pyx",
        "smoke/replay/match.pyx",
        "smoke/replay/ticker.pyx",
        "smoke/model/entity.pyx",
        "smoke/replay/flattening.pyx",
    ])
)
