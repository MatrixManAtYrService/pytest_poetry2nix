from myapp.cli import greeting

def test_hello():
    assert greeting() == "hello"
