Hola Ing. Guirola,

Para los ejercicios de lenguaje ensamblador, comencé desarrollando las versiones básicas según los requerimientos iniciales de cada uno. Para la resta, me enfoqué en usar solo registros de 16 bits para las operaciones 
con tres enteros que definí directamente en el código. De forma similar, para la multiplicación, utilicé registros de 8 bits para los dos números y la instrucción mul, considerando que el resultado podría 
ocupar 16 bits en ax. En el caso de la división, apliqué registros de 32 bits, preparando el dividendo en edx:eax con la ayuda de cdq antes de usar idiv, y obteniendo el cociente en eax y el residuo en edx. 
En estas versiones básicas, los programas hacían el cálculo internamente y terminaban, cumpliendo con las restricciones de tamaño de registro y como lo pedian los requerimientos en el documente que subio a campus.

Luego, decidí que quería mejorar estos programas para hacerlos un poco más interactivos y completos. Por eso, para cada ejercicio, implementé una versión mejorada que incluye un mensaje de bienvenida, 
le pide los números al usuario desde el teclado y, lo más importante, muestra el resultado de la operación en pantalla. Esto presentó algunos retos interesantes, como tener que desarrollar rutinas para convertir el texto 
que el usuario ingresa (cadenas de caracteres) a números enteros con(string_to_int) del tamaño adecuado (8, 16 o 32 bits) y viceversa, convertir el resultado numérico de vuelta a una cadena de texto para poder imprimirlo. 
También tuve detalles como el manejo del signo en las conversiones, la correcta preparación de los operandos para instrucciones como idiv, y la gestión de los registros para que no se sobrescribieran valores importantes 
entre llamadas a funciones o syscalls, lo que requirió guardar y restaurar registros en la pila en algunos casos. Además, para asegurar que los programas se enlazaran correctamente en mi sistema Linux de debian de 64 bits 
sin las bibliotecas estándar de C, utilicé gcc con la opción de -nostdlib y -no-pie para hacer el enlace depues de compilar. Aunque el requerimiento inicial era más simple, creo que estas mejoras me permitieron profundizar 
mucho más en el manejo de la entrada/salida y la manipulación de datos en ensamblador, porque tuve que investigar muchos recursos para desarrollar esto ya que pense al inicio que seria muy facil pero no lo fue tanto.

Aqui trato de explicar como hice el codigo para cada ejercicio
