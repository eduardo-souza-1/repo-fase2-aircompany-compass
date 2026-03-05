import pytest
from calculadora import Calculadora
 
@pytest.mark.parametrize("num1, num2, resultado", [
    (5, 4, 9),
    (-6, -6, -12),
    (5, 0, 5),
])
def test_somar(num1, num2, resultado):
    calculo = Calculadora()
    assert calculo.somar(num1, num2) == resultado
 
@pytest.mark.parametrize("num1, num2, resultado", [
    (10, 3, 7),
    (3, 7, -4),
    (9, 0, 9),
])
def test_subtrair(num1, num2, resultado):
    calculo = Calculadora()
    assert calculo.subtrair(num1, num2) == resultado
 
@pytest.mark.parametrize("num1, num2, resultado", [
    (5, 5, 25),
    (5, 0, 0),
    (-3, 4, -12),
])
def test_multiplicar(num1, num2, resultado):
    calculo = Calculadora()
    assert calculo.multiplicar(num1, num2) == resultado
 
@pytest.mark.parametrize("num1, num2, resultado", [
    (10, 2, 5),
    (7, 2, 3.5),
])
def test_dividir(num1, num2, resultado):
    calculo = Calculadora()
    assert calculo.dividir(num1, num2) == resultado
 
def test_dividir_por_zero():
    calculo = Calculadora()
    with pytest.raises(ValueError):
        calculo.dividir(6, 0)
 

 