// Reference to object provided by pengines.js library which interfaces with Pengines server (Prolog-engine)
// by making query requests and receiving answers.
var pengine;
// Bidimensional array representing board configuration.
var gridData;
// Bidimensional array with board cell elements (HTML elements).
var cellElems;
// States if it's black player turn.
var turnBlack = false;
var bodyElem;
var latestStone;
var cantFichasNegras;
var cantFichasBlancas;
var turnosPasados;
var territorioBlanco;
var territorioNegro;
var finalizar;


/**
* Initialization function. Requests to server, through pengines.js library,
* the creation of a Pengine instance, which will run Prolog code server-side.
*/

function init() {
    document.getElementById("passBtn").addEventListener('click', () => switchTurn());
    bodyElem = document.getElementsByTagName('body')[0];
    createBoard();
    // Creación de un conector (interface) para comunicarse con el servidor de Prolog.
    pengine = new Pengine({
        server: "http://localhost:3030/pengine",
        application: "proylcc",
        oncreate: handleCreate,
        onsuccess: handleSuccess,
        onfailure: handleFailure,
        destroy: false
    });
    cantFichasNegras=0;
    cantFichasBlancas=0;
    finalizar=false;
}

/**
 * Create grid cells elements
 */

function createBoard() {
    const dimension = 19;
    const boardCellsElem = document.getElementById("boardCells");
    for (let row = 0; row < dimension - 1; row++) {
        for (let col = 0; col < dimension - 1; col++) {
            var cellElem = document.createElement("div");
            cellElem.className = "boardCell";
            boardCellsElem.appendChild(cellElem);
        }
    }
    const gridCellsElem = document.getElementById("gridCells");
    cellElems = [];
    for (let row = 0; row < dimension; row++) {
        cellElems[row] = [];
        for (let col = 0; col < dimension; col++) {
            var cellElem = document.createElement("div");
            cellElem.className = "gridCell";
            cellElem.addEventListener('click', () => handleClick(row, col));
            gridCellsElem.appendChild(cellElem);
            cellElems[row][col] = cellElem;
        }
    }
}

/**
 * Callback for Pengine server creation
 */

function handleCreate() {
    finalizar=false;
    pengine.ask('emptyBoard(Board)');
}

/**
 * Callback for successful response received from Pengines server.
 */

function handleSuccess(response) {
    if(finalizar){
        territorioNegro= response.data[0].PuntajeNegras;
        territorioBlanco= response.data[0].PuntajeBlancas;

        var puntajeN= territorioNegro.length;
        var puntajeB= territorioBlanco.length;

        puntajeN+= cantFichasNegras;
        puntajeB+= cantFichasBlancas;
        alert("Puntaje Blancas= "+puntajeB+"\nPuntaje Negras= "+puntajeN);
        handleCreate();
    }
    else{
        cantFichasNegras=0;
        cantFichasBlancas=0;
        gridData = response.data[0].Board;
        for (let row = 0; row < gridData.length; row++)
            for (let col = 0; col < gridData[row].length; col++) {
              cellElems[row][col].className = "gridCell" +
              (gridData[row][col] === "w" ? " stoneWhite" : gridData[row][col] === "b" ? " stoneBlack" : "") +
              (latestStone && row === latestStone[0] && col === latestStone[1] ? " latest" : "");

              //Recuento de puntajes parciales.
              if(gridData[row][col]=="w")
                  cantFichasBlancas++;
              if(gridData[row][col]=="b")
                  cantFichasNegras++;
            }

        turnosPasados=0;
        pasarTurnoTablero();
    }
}

/**
 * Called when the pengine fails to find a solution.
 */

function handleFailure() {
    alert("Invalid move!");
}

/**
 * Handler for color click. Ask query to Pengines server.
 */

function handleClick(row, col) {
    const s = "goMove(" + Pengine.stringify(gridData) + "," + Pengine.stringify(turnBlack ? "b" : "w") + "," + "[" + row + "," + col + "]" + ",Board)";
    pengine.ask(s);
    latestStone = [row, col];
}

function switchTurn() {
    turnosPasados++;
    if(turnosPasados==2)
      finalizarJuego();
    pasarTurnoTablero();
}

function pasarTurnoTablero(){
    turnBlack = !turnBlack;
    bodyElem.className = turnBlack ? "turnBlack" : "turnWhite";
    document.getElementById("puntaje Negro").innerHTML= "Puntaje Negras: "+cantFichasNegras;
    document.getElementById("puntaje Blanca").innerHTML= "Puntaje Blancas: "+cantFichasBlancas;
}

function finalizarJuego(){
    finalizar= true;
    const puntaje= "contarPuntaje(" + Pengine.stringify(gridData) + ",PuntajeBlancas,PuntajeNegras)";
    pengine.ask(puntaje);
    turnosPasados=0;
    if(!turnBlack)
      pasarTurnoTablero();
}



/**
* Call init function after window loaded to ensure all HTML was created before
* accessing and manipulating it.
*/

window.onload = init;
