# Hands-on 1: Análisis Léxico y Autómatas

## Objetivo

Desarrollar un programa cuya **entrada sea una instrucción del Instruction Set Architecture (ISA)** definido en esta práctica y cuya **salida muestre su identificación, el objeto instrucción y la secuencia de microoperaciones correspondiente**.

El programa deberá:

1. Validar la instrucción mediante un **autómata finito determinista (AFD)**.
2. Identificar el mnemónico y sus operandos (argumentos).
3. Construir el objeto instrucción (i.e. representación alterna para una Máquina de Moore).
4. Emplear una **máquina de Moore** para generar e imprimir las microoperaciones en el orden establecido.

**No se requiere ejecutar las microoperaciones, modificar registros ni implementar un simulador gráfico.**

## 1. Entrada y salida del programa

### Entrada

Una instrucción textual perteneciente al ISA de referencia. Por ejemplo:

```text
MOV AL, 6
```

### Salida

El programa deberá imprimir:

- El resultado de la validación.
- Los tokens reconocidos.
- El mnemónico, los registros y las direcciones identificados, según corresponda.
- El objeto instrucción.
- La secuencia de microoperaciones generada por la máquina de Moore.

**Si la instrucción es inválida, deberá imprimir el error y detener su procesamiento, sin generar microoperaciones.**

## 2. Arquitectura de referencia e ISA

Se utilizará el repertorio de instrucciones de la animación, en su representación textual. No se asignarán códigos binarios nuevos.

### Componentes de la arquitectura

| Componente | Función |
|---|---|
| `AL`, `BL` | Registros para los operandos |
| `ACC` | Acumulador donde se deposita el resultado de la suma |
| `MAR` | Registro que contiene la dirección de memoria que se utilizará i.e. representación alterna para una Máquina de Moore|
| `MBR` | Registro que contiene el dato leído de memoria o que se escribirá en ella |
| `M[d]` | Contenido de memoria en la dirección `d` |

### Conjunto de instrucciones admitidas

| Formato | Operandos permitidos | Significado |
|---|---|---|
| `MOV R, d` | `R`: `AL` o `BL`; `d`: dirección decimal no negativa | Cargar en `R` el contenido de `M[d]` |
| `ADD AL, BL` | `AL` y `BL`, en ese orden | Sumar ambos registros y depositar el resultado en `ACC` |
| `STO d` | `d`: dirección decimal no negativa | Almacenar el contenido de `ACC` en `M[d]` |
| `END` | Sin operandos | Detener la ejecución |

**Mnemónico:** nombre simbólico de la operación, como `MOV`, `ADD`, `STO` o `END`.

**Direccionamiento directo:** en `MOV` y `STO`, el operando numérico identifica una dirección de memoria. Por ejemplo:

```text
MOV AL, 6  →  AL ← M[6]
```

Esto significa cargar el contenido de la dirección `6`, no cargar el número `6`.

**Convenciones de entrada:**

- Mnemónicos y registros en mayúsculas.
- Uno o más espacios entre el mnemónico y sus operandos.
- Coma obligatoria en `MOV` y `ADD`; espacios opcionales alrededor de ella.
- Dirección formada por uno o más dígitos decimales.
- Sin operandos adicionales.

No se comprobará la existencia física de la dirección de memoria.

## 3. Microoperaciones de referencia

La máquina de Moore deberá generar las siguientes secuencias, **respetando su orden**:

| Instrucción validada | Primera microoperación | Segunda microoperación | Tercera microoperación |
|---|---|---|---|
| `MOV AL, d` | `MAR ← d` | `MBR ← M[MAR]` | `AL ← MBR` |
| `MOV BL, d` | `MAR ← d` | `MBR ← M[MAR]` | `BL ← MBR` |
| `ADD AL, BL` | `ACC ← AL + BL` | — | — |
| `STO d` | `MAR ← d` | `MBR ← ACC` | `M[MAR] ← MBR` |
| `END` | `HALT ← 1` | — | — |

El símbolo `←` representa transferencia o asignación. La suma se modela como una sola microoperación, sin introducir registros auxiliares.

La práctica comienza con la instrucción ya disponible para su análisis: **no se requiere generar las microoperaciones de fetch**.

## 4. Procesamiento que debe implementar el programa

### A. Validación e identificación mediante el AFD

El AFD deberá recorrer la entrada carácter por carácter, reconocer sus componentes y comprobar que la instrucción completa corresponde a un formato admitido.

Para `MOV AL, 6`, deberá identificar:

| Lexema | Token | Interpretación |
|---|---|---|
| `MOV` | `MOV` | Mnemónico de la operación |
| `AL` | `REGISTRO` | Registro destino |
| `,` | `COMA` | Separador |
| `6` | `NUMERO` | Operando que, en esta instrucción, representa una dirección |

No basta con reconocer lexemas válidos: también deberá comprobarse su orden y que no falten ni sobren componentes.

### B. Construcción del objeto instrucción

Una vez validada la entrada, el programa organizará la información reconocida en un objeto. Por ejemplo:

```text
{
    operacion: "MOV",
    registros: ["AL"],
    direccion: 6
}
```

Para las demás instrucciones:

```text
ADD AL, BL → { operacion: "ADD", registros: ["AL", "BL"], direccion: null }
STO 8      → { operacion: "STO", registros: [], direccion: 8 }
END        → { operacion: "END", registros: [], direccion: null }
```

### C. Generación mediante la máquina de Moore

La máquina de Moore recibirá el objeto instrucción y seleccionará la ruta de estados correspondiente. **No volverá a analizar el texto.**

Cada estado tendrá una salida asociada que describe una microoperación. Por ejemplo, para `MOV AL, 6`:

| Estado | Salida asociada | Siguiente estado |
|---|---|---|
| Preparar dirección | `MAR ← dirección` | Leer memoria |
| Leer memoria | `MBR ← M[MAR]` | Cargar AL |
| Cargar AL | `AL ← MBR` | Fin |
| Fin | Ninguna | Terminar la generación |

La dirección se conserva como parámetro del objeto: al imprimir `MAR ← dirección`, se sustituye por `6`. **El estado determina qué operación se emite; el objeto aporta el operando.**

Cada llamada a `siguientePaso()` emitirá la salida del estado actual y avanzará al siguiente. El programa repetirá este procedimiento hasta llegar a `Fin`.

## 5. Ejemplo completo de entrada y salida

```text
ENTRADA
MOV AL, 6

VALIDACIÓN MEDIANTE AFD
Instrucción válida.

TOKENS RECONOCIDOS
MOV("MOV")
REGISTRO("AL")
COMA(",")
NUMERO("6")

COMPONENTES IDENTIFICADOS
Mnemónico: MOV
Registro destino: AL
Dirección de memoria: 6
Direccionamiento: directo

OBJETO INSTRUCCIÓN
{
    operacion: "MOV",
    registros: ["AL"],
    direccion: 6
}

MICROOPERACIONES GENERADAS POR MOORE
1. MAR ← 6
2. MBR ← M[MAR]
3. AL ← MBR

Generación terminada.
```

Ejemplo de rechazo:

```text
ENTRADA
MOV AL 6

VALIDACIÓN MEDIANTE AFD
Instrucción inválida: falta la coma entre el registro y la dirección.

No se construye el objeto instrucción.
No se generan microoperaciones.
```

## 6. Entrega y pruebas

Entregar el código fuente y evidencias de ejecución con las siguientes entradas:

| Entradas válidas | Entradas inválidas |
|---|---|
| `MOV AL, 6` | `MOV AX, 6` |
| `MOV BL, 7` | `MOV AL 6` |
| `ADD AL, BL` | `ADD AL,` |
| `STO 8` | `STO` |
| `END` | `END 8` |

Se evaluará:

- La implementación explícita de estados y transiciones del AFD.
- La identificación correcta de los componentes y la construcción del objeto.
- El recorrido de estados de Moore con salidas asociadas.
- La impresión de las microoperaciones correctas y ordenadas.

**Resultado esperado:** introducir una instrucción, identificarla y obtener su secuencia de microoperaciones, sin ejecutarla.

