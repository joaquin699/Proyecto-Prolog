:- module(proylcc,
	[
		emptyBoard/1,
		goMove/4,
		contarPuntaje/3
	]).

:- dynamic fichaVisitada/1.

%
% emptyBoard(-Board)
%
% Board es la configuracion de un tablero vacio.

emptyBoard([
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"]
		 ]).

%
% goMove(+Board, +Player, +Pos, -RBoard)
%
% RBoard es la configuración resultante de reflejar la movida del jugador Player
% en la posición Pos a partir de la configuración Board.
goMove(Board, Player, [R,C], RBoard):-
		replace(Row, R, NRow, Board, TableroTemporal),
		replace("-", C, Player, Row, NRow),
		obtenerPosicionesAdyacentes([R,C],AdyacentesPlayer),
		obtenerColorContrario(Player,ColorContrario),
		obtenerFichasCapturadas(TableroTemporal,AdyacentesPlayer,ColorContrario,Player,FichasCapturadas),
		FichasCapturadas\=[],
		eliminarCapturadas(TableroTemporal,FichasCapturadas,RBoard).

goMove(Board,Player,[R,C],RBoard):-
		replace(Row, R, NRow, Board, TableroTemporal),
		replace("-", C, Player, Row, NRow),
		obtenerPosicionesAdyacentes([R,C],AdyacentesPlayer),
		obtenerColorContrario(Player,ColorContrario),
		obtenerFichasCapturadas(TableroTemporal,AdyacentesPlayer,ColorContrario,Player,FichasCapturadas),
		FichasCapturadas=[],
		not(conjuntoCapturado(TableroTemporal,[R,C],[],Player,ColorContrario,_TotalVisitadas,_Capturadas)),
		RBoard=TableroTemporal.


%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
replace(X, 0, Y, [X|Xs], [Y|Xs]).
replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
		XIndex > 0,
		XIndexS is XIndex - 1,
		replace(X, XIndexS, Y, Xs, XsY).

%
%	unirConjuntos(+C1,+C2,-C)
%
% Retorna en C la union de los conjuntos C1 y C2.
unirConjuntos([],C2,C2).
unirConjuntos([C|C1],C2,Conjunto):- unirConjuntos(C1,C2,CAux),incorporar(C,CAux,Conjunto).

%
% incorporar(+X,+C1,-C)
%
% Dado un elemento de entrada X y un conjunto C1, si X pertenece a C1 retorna este mismo
% conjunto, caso contrario retorna C1 con la incorporacion de X.
incorporar(X,C,[X|C]):- not(member(X,C)).
incorporar(X,C,C):- member(X,C).

%
% obtenerColorContrario(+c,-cc)
%
obtenerColorContrario("b","w").
obtenerColorContrario("w","b").

%
% obtenerContenidoDePosicion(+Board,+Pos,-C)
%
% retorna en C el contenido asociado a esa posicion dentro del tablero.
obtenerContenidoDePosicion(Board,[R,C],Contenido):-
		replace(Row,R,NRow,Board,_NBoard),
		replace(Contenido,C,Contenido,Row,NRow).

%
% obtenerPosicionesAdyacentes(+Pos,-ListaAdyacentes)
%
% retorna en ListaAdyacentes las posiciones adyacentes de la posicion, la lista puede contener
% dos, tres o cuatro posiciones dependiendo de su ubicacion en el tablero.
obtenerPosicionesAdyacentes([R,C],ListaPosicionesAdyacentes):-
		R1 is R-1,
		R2 is R+1,
		C1 is C-1,
		C2 is C+1,
		obtenerPosicion([R,C1],Pos1),
		obtenerPosicion([R,C2],Pos2),
		obtenerPosicion([R1,C],Pos3),
		obtenerPosicion([R2,C],Pos4),
		ListaAdyacentesAuxiliar=[Pos1,Pos2,Pos3,Pos4],
		eliminarPosicionesVacias(ListaAdyacentesAuxiliar,ListaPosicionesAdyacentes).

%
% obtenerPosicion(+Pos,-Posicion)
%
% verifica que la posicion pasada este dentro de los limites del tablero, si esto no sucede retorna []
obtenerPosicion([R,C],[]):-
		R<0;
		R>18;
		C<0;
		C>18.
obtenerPosicion([R,C],[R,C]):-
		R>=0,
		R=<18,
		C>=0,
		C=<18.

%
%	eliminarPosicionesVacias(+C,-CSV)
%
% Dado un conjunto de entrada de posiciones C, elimina las posibles posiciones vacias.
eliminarPosicionesVacias([],[]).
eliminarPosicionesVacias([[]|Posiciones],PosicionesSinVacio):-
		eliminarPosicionesVacias(Posiciones,PosicionesSinVacio).
eliminarPosicionesVacias([P|Posiciones],[P|PosicionesSinVacio]):-
		P\= [],
	 	eliminarPosicionesVacias(Posiciones,PosicionesSinVacio).


%
%	eliminarCapturadas(+Board,+ListaPosiciones,-RBoard)
%
% elimina las posiciones de la lista del tablero Board.
% RBoard representa la configuracion del tablero resultante de eliminar todas las posiciones en la lista.
eliminarCapturadas(Board,[],Board).
eliminarCapturadas(Board,[Pos|FichasAEliminar],RBoard):-
		eliminarCapturadas(Board,FichasAEliminar,TableroAux),
		eliminarFicha(TableroAux,Pos,RBoard).

%
% eliminarFicha(+Board,+Pos,-RBoard)
%
% elimina la posicion Pos del tablero.
% RBoard es la configuracion del tablero resultante de eliminar la Posicion Pos.
eliminarFicha(Board,[R,C],RBoard):-
		replace(Row, R, NRow, Board, RBoard),
		replace(_, C, "-", Row, NRow).

%
%	sePuedeCapturar(+Board,+Adyacentes,+Rodeado,+ColorRodeador)
%
% Verifica si un conjunto de adyacentes puede capturar a una ficha.
sePuedeCapturar(_Board,[],_Rodeado,_ColorRodeador).
sePuedeCapturar(Board,[Pos|Adyacentes],Rodeado,ColorRodeador):-
		obtenerContenidoDePosicion(Board,Pos,Rodeado),
		sePuedeCapturar(Board,Adyacentes,Rodeado,ColorRodeador).
sePuedeCapturar(Board,[Pos|Adyacentes],Rodeado,ColorRodeador):-
		obtenerContenidoDePosicion(Board,Pos,ColorRodeador),
		sePuedeCapturar(Board,Adyacentes,Rodeado,ColorRodeador).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% conjuntoCapturado(+Board,+Pos,+PosicionesVisitadas,+Rodeado,+ColorRodeador,-TotalVisitadas,-FichasCapturadas)
%
conjuntoCapturado(Board,Pos,PosicionesVisitadas,Rodeado,ColorRodeador,TotalVisitadas,FichasCapturadas):-
		obtenerPosicionesAdyacentes(Pos,PosicionesAdyacentes),
		sePuedeCapturar(Board,PosicionesAdyacentes,Rodeado,ColorRodeador),
		analizarPosicionesAdyacentes(Board,PosicionesAdyacentes,[Pos|PosicionesVisitadas],Rodeado,ColorRodeador,TotalVisitadas,FichasCapturadas1),
		FichasCapturadas= [Pos|FichasCapturadas1].

%
% analizarPosicionesAdyacentes(+Board,+ListaAdyacentes,+PosicionesVisitadas,+Rodeado,+ColorRodeador,-TotalVisitadas,-FichasCapturadas)
%
analizarPosicionesAdyacentes(_Board,[],PosicionesVisitadas,_Rodeado,_ColorContrario,PosicionesVisitadas,[]).
analizarPosicionesAdyacentes(Board,[ElementoAdyacente|Adyacentes],PosicionesVisitadas,Rodeado,ColorRodeador,TotalVisitadas,FichasCapturadas):-
		estaCapturada(Board,ElementoAdyacente,PosicionesVisitadas,Rodeado,ColorRodeador,NVisitadas,FichasCapturadas1),
		analizarPosicionesAdyacentes(Board,Adyacentes,NVisitadas,Rodeado,ColorRodeador,TotalVisitadas,FichasCapturadas2),
		unirConjuntos(FichasCapturadas1,FichasCapturadas2,FichasCapturadas).

%
%	estaCapturada(+Board,+Pos,+PosicionesVisitadas,+Rodeado,+ColorRodeador,-TotalVisitadas,-FichasCapturadas)
%
estaCapturada(Board,Pos,PosicionesVisitadas,_Rodeado,ColorRodeador,TotalVisitadas,[]):-
		obtenerContenidoDePosicion(Board,Pos,ColorRodeador),
		TotalVisitadas=[Pos|PosicionesVisitadas].
estaCapturada(Board,Pos,PosicionesVisitadas,Rodeado,_ColorRodeador,PosicionesVisitadas,[]):-
		member(Pos,PosicionesVisitadas),
		obtenerContenidoDePosicion(Board,Pos,Rodeado).
estaCapturada(Board,Pos,PosicionesVisitadas,Rodeado,ColorContrario,TotalVisitadas,FichasCapturadas):-
		not(member(Pos,PosicionesVisitadas)),
		obtenerContenidoDePosicion(Board,Pos,Rodeado),
		conjuntoCapturado(Board,Pos,PosicionesVisitadas,Rodeado,ColorContrario,TotalVisitadas,FichasCapturadas).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	obtenerFichasCapturadas(+Board,+Adyacentes,+Rodeado,+ColorRodeador,-FichasCapturadas)
%
% Retorna en FichasCapturadas un conjunto con las posiciones capturadas por ColorRodeador,
% a partir de las Adyacentes.
obtenerFichasCapturadas(_Board,[],_Rodeado,_Color,[]).
obtenerFichasCapturadas(Board,[Pos|Adyacentes],Rodeado,ColorRodeador,FichasCapturadas):-
		obtenerContenidoDePosicion(Board,Pos,Contenido),
		Contenido=Rodeado,
		conjuntoCapturado(Board,Pos,[],Rodeado,ColorRodeador,_TotalVisitadas,Capturadas1),
		obtenerFichasCapturadas(Board,Adyacentes,Rodeado,ColorRodeador,Capturadas2),
		unirConjuntos(Capturadas1,Capturadas2,FichasCapturadas).
obtenerFichasCapturadas(Board,[_Pos|Adyacentes],Rodeado,ColorRodeador,FichasCapturadas):-
		obtenerFichasCapturadas(Board,Adyacentes,Rodeado,ColorRodeador,FichasCapturadas).


%
% siguientePosicion(+Pos,-SPos)
%
% Dada una posicion retorna la siguiente posicion en el tablero
siguientePosicion([18,18],[18,18]).
siguientePosicion([F,18],[F1,0]):-
		F\=18,
		F1 is F+1.
siguientePosicion([F,C],[F,C1]):-
		C\=18,
		C1 is C+1.

%
% buscarNulas(+Board,+Pos,-ListaPosicionesNulas)
%
% Retorna las posiciones Nulas del tablero
buscarNulas(Board,[18,18],MiColor,ListaNulas):-
		obtenerContenidoDePosicion(Board,[18,18],"-"),
		obtenerPosicionesAdyacentes([18,18],Adyacentes),
		verificarColorAdyacentes(Board,MiColor,Adyacentes),
		ListaNulas=[[18,18]].

buscarNulas(_,[18,18],_,[]).

buscarNulas(Board,[R,C],MiColor,ListaNulas):-
		[R,C]\=[18,18],
		obtenerContenidoDePosicion(Board,[R,C],"-"),
		obtenerPosicionesAdyacentes([R,C],Adyacentes),
		verificarColorAdyacentes(Board,MiColor,Adyacentes),
	 	siguientePosicion([R,C],Pos),
		buscarNulas(Board,Pos,MiColor,ListaAux),
		ListaNulas=[[R,C]|ListaAux].

buscarNulas(Board,[R,C],MiColor,Lista):-
		[R,C]\=[18,18],
		siguientePosicion([R,C],Pos),
		buscarNulas(Board,Pos,MiColor,Lista).



verificarColorAdyacentes(Board,MiColor,[X|_]):-
		obtenerContenidoDePosicion(Board,X,Contenido),
		MiColor=Contenido.

verificarColorAdyacentes(Board,MiColor,[_|Lista]):-
		verificarColorAdyacentes(Board,MiColor,Lista).

%
%	diferencia(C1,C2,C)
%
%	Dados dos conjuntos C1 y C2, retorna en C la diferencia de estos conjuntos, esto
% es, C= C1-C2.
diferencia([],_C2,[]).
diferencia([C|C1],C2,[C|CAux]):- not(member(C,C2)),diferencia(C1,C2,CAux).
diferencia([C|C1],C2,Conj):- member(C,C2),diferencia(C1,C2,Conj).


%
%	contarPuntaje(+Board,-CapturadasPorNegras,-CapturadasPorBlancas)
%
% Retorna en el conjunto de fichas nulas capturadas por las fichas blancas y negras.
contarPuntaje(Board,CapturadasPorBlancas,CapturadasPorNegras):-
		buscarNulas(Board,[0,0],"w",ListaNulasBlancas),
		capturarPosicionesNulas(Board,ListaNulasBlancas,"-","w",CapturadasPorBlancas),
		buscarNulas(Board,[0,0],"b",ListaNulasNegras),
		capturarPosicionesNulas(Board,ListaNulasNegras,"-","b",CapturadasPorNegras).
%
%	capturarPosicionesNulas(+Board,+ListaNulas,+Rodeado,+ColorRodeador,-TotalCapturadas)
%
% Dada la lista de posiciones nulas del Tablero Board, retorna en TotalCapturadas todas las
% fichas nulas rodeadas por el ColorRodeador.
capturarPosicionesNulas(_Board,[],_Rodeado,_ColorRodeador,[]).
capturarPosicionesNulas(Board,[Pos|ListaNula],Rodeado,ColorRodeador,TotalCapturados):-
		conjuntoCapturado(Board,Pos,[],Rodeado,ColorRodeador,_TotalCapturadas,Capturadas),
		diferencia([Pos|ListaNula],Capturadas,ListaNulaSinCapturadas),
		capturarPosicionesNulas(Board,ListaNulaSinCapturadas,Rodeado,ColorRodeador,CapturadosParcial),
		unirConjuntos(Capturadas,CapturadosParcial,TotalCapturados).
capturarPosicionesNulas(Board,[_Pos|ListaNula],Rodeado,ColorRodeador,TotalCapturados):-
		capturarPosicionesNulas(Board,ListaNula,Rodeado,ColorRodeador,TotalCapturados).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

longitudLista([],0).
longitudLista([_X|Lista],Long):- longitudLista(Lista,LL),Long is LL+1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
