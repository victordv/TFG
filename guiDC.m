%Victor del Valle del Apio
%victorvalleapio@gmail.com
%Julio de 2015

%Aplicacion del coloreado del dominio de funciones complejas

function varargout = guiDC(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @guiDC_OpeningFcn, ...
                       'gui_OutputFcn',  @guiDC_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end

function guiDC_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    pushbutton1_Callback(hObject, eventdata, handles)
end

function varargout = guiDC_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

%Funcion principal
function pushbutton1_Callback(hObject, eventdata, handles)
    %Limpiamos los ejes
    cla
    hold on
    
    %Obtenemos la funcion a evaluar
    fun = get(handles.edit1, 'String');
    
    %Datos de las matrices de colores
    numpointsR = 120;
    numpointsTheta = 120;
    numpointsX1 = 120;
    numpointsY1 = 120;
  
    %Obtenemos el valor de la precision
    slider1 = get(handles.slider1,'value');
    if(slider1==0)
        numpointsR = 120;
        numpointsTheta = 120;
        numpointsX1 = 98;
        numpointsY1 = 98;
    elseif(slider1==0.5)
        numpointsR = 240;
        numpointsTheta = 240; 
        numpointsX1 = 198;
        numpointsY1 = 198;
    elseif(slider1==1)
        numpointsR = 360;
        numpointsTheta = 360;
        numpointsX1 = 298;
        numpointsY1 = 298;
    end
    
    %Obtenemos los extremos de los intervalos    
    intervaloX1 = str2double(get(handles.edit2, 'String'));
    intervaloX2 = str2double(get(handles.edit3, 'String'));
    intervaloY1 = str2double(get(handles.edit4, 'String'));
    intervaloY2 = str2double(get(handles.edit5, 'String'));
    intervalos = [intervaloX1,intervaloX2,intervaloY1,intervaloY2];

    %Evaluamos la funcion en cada punto contenido en los intervalos
    Z = matrizEval(fun,intervalos,numpointsX1,numpointsY1);

    %Delimitamos los extremos del modulo y del argumento
    extremoTheta = 2*pi;
    extremoR = maxR(Z,numpointsX1,numpointsY1);

    %Obtenemos si se quieren pintar las curvas de nivel
    pintarContour = get(handles.checkbox1, 'Value');
    numContour = 21;
    
    %Obtenemos la oscuridad de los colores
    slider2 = get(handles.slider2,'value');
    if(slider2 <= 0.5) 
        pond = slider2;
    else
        pond = slider2*extremoR/2;
    end
    
    %Pintamos la matriz de referencia
    matrizRGB = colorMatriz(numpointsR,numpointsTheta,extremoTheta);

    %Pintamos la matriz de la funcion
    colorFuncion(Z, matrizRGB,numpointsR,numpointsTheta,extremoR,pond,extremoTheta,numpointsX1,numpointsY1,intervalos,pintarContour, numContour);
    hold off
end

%Metodo que evalua la funcion
function Z = matrizEval(fun,intervalos,numpointsX1,numpointsY1)
    %Dividimos los intervalos en puntos
    x1 = linspace(intervalos(1),intervalos(2),numpointsX1);
    y1 = linspace(intervalos(3),intervalos(4),numpointsY1);
    [X,Y] = meshgrid(x1,y1);

    %Evaluamos la funcion para cada uno de los puntos
    z = X + 1i*Y;
    vectZ = vectorize(fun);
    Z = feval(inline(vectZ),z);
    
    %Si la funcion es constante, creamos la matriz llena de la constante
    if(size(Z,1)~=numpointsX1)
        Z = zeros(numpointsX1)+str2num(fun);
    end
    %Giramos la funcion para visualizarla correctamente
    Z = rot90(Z,3);
end

%Funcion que calcula el valor maximo del modulo de los puntos dentro del intervalo
function moduloMaximo = maxR(Z,numpointsX1,numpointsY1)
    %Vamos a comprobar si la funcion es una constante
    valor = Z(1,1);
    esIgual = true;
    
    %Guardamos en una matriz los modulos de cada punto
    matrizModulos = zeros(numpointsX1,numpointsY1);
    for i=1:numpointsX1
       for j=1:numpointsY1
           eval=Z(i,j);
           if(eval~=valor)
               esIgual=false;
           end
           matrizModulos(i,j)= abs(eval);
       end
    end
   
    %Nos quedamos con el maximo de la matriz de modulos
    maximoFila = max(matrizModulos);
    moduloMaximo = max(maximoFila);
    moduloMaximo = ceil(moduloMaximo);
    
    %Si la funcion es constante, ponemos un modulo mayor para su correcta vision
    if(esIgual==true)
        moduloMaximo = moduloMaximo*4;
    end
end

%Funcion que calcula la matriz de referencia con los colores
function matrizRGB = colorMatriz(numpointsR,numpointsTheta,extremoTheta)
    theta = linspace(0, extremoTheta, numpointsTheta);
    matrizRGB = zeros(2*numpointsR,numpointsTheta,3);
    for modulo=1:numpointsR
       for argumento=1:numpointsTheta 
           %Rellenamos la matrizRGB en dos pasos: la primera del negro a los colores RGB, y la segunda de los colores RGB al blanco

           %Primer paso:
           %Dividimos el plano en 6 sectores, y se pinta cada uno de ellos del color correspondiente. Luego se atenua hacia el propio color o hacia el negro [0 0 0].

           %     Verde [0 1 0]         Amarillo [1 1 0] 
           %                  \       /
           %                   \     /
           %                    \   /
           %                     \ /
           % Cyan [0 1 1] ---------------- Rojo [1 0 0] 
           %                     / \ 
           %                    /   \
           %                   /     \
           %                  /       \
           %      Azul [0 0 1]         Magenta [1 0 1]
           %
           
           sector = numpointsTheta/6;
           %Colores entre el rojo y amarillo.
           if theta(argumento)<=pi/3
               matrizRGB(modulo,argumento,:) = [1 0 0] + (argumento/sector)*[0 1 0];
               
           %Colores entre el amarillo y verde.    
           elseif theta(argumento)>pi/3 && theta(argumento)<=2*pi/3
               matrizRGB(modulo,argumento,:) = [0 1 0] + (1-((argumento-sector)/sector))*[1 0 0];
               
           %Colores entre el verde y cyan.    
           elseif theta(argumento)>2*pi/3 && theta(argumento)<=pi
               matrizRGB(modulo,argumento,:) = [0 1 0] + ((argumento-2*sector)/sector)*[0 0 1];
               
           %Colores entre el cyan y azul.    
           elseif theta(argumento)>pi && theta(argumento)<=4*pi/3
               matrizRGB(modulo,argumento,:) = [0 0 1] + (1-((argumento-3*sector)/sector))*[0 1 0];
               
           %Colores entre el azul y magenta.    
           elseif theta(argumento)>4*pi/3 && theta(argumento)<=5*pi/3
               matrizRGB(modulo,argumento,:) = [0 0 1] + ((argumento-4*sector)/sector)*[1 0 0];
               
           %Colores entre el magenta y rojo.    
           else
               matrizRGB(modulo,argumento,:) = [1 0 0] + (1-((argumento-5*sector)/sector))*[0 0 1]; 
           end

           %Obtenemos el color para usarlo posteriormente en el segundo paso.
           R = matrizRGB(modulo,argumento,1);
           G = matrizRGB(modulo,argumento,2);
           B = matrizRGB(modulo,argumento,3);

           %Se atenua el valor, haciendolo totalmente negro en valores cercanos al cero.
           matrizRGB(modulo,argumento,:)= matrizRGB(modulo,argumento,:)*(modulo/numpointsR);

           %Segundo paso:
           %Con el color que se tiene en ese momento (caracterizado por RGB), se atenua hacia el blanco. Esos valores van aumentanto progresivamente (cada uno de ellos a su ritmo) hasta el [1 1 1].
           nuevoModulo = modulo+numpointsR;
           if R==1
               matrizRGB(nuevoModulo,argumento,1)=1;
           elseif R==0
               matrizRGB(nuevoModulo,argumento,1)=(modulo/numpointsR);
           else matrizRGB(nuevoModulo,argumento,1) = R+((1-R)*modulo/numpointsR);
           end
           if G==1
               matrizRGB(nuevoModulo,argumento,2)=1;
           elseif G==0
               matrizRGB(nuevoModulo,argumento,2)=(modulo/numpointsR);
           else matrizRGB(nuevoModulo,argumento,2) = G+((1-G)*modulo/numpointsR);
           end
           if B==1
               matrizRGB(nuevoModulo,argumento,3)=1;
           elseif B==0
               matrizRGB(nuevoModulo,argumento,3)=(modulo/numpointsR);
           else matrizRGB(nuevoModulo,argumento,3) = B+((1-B)*modulo/numpointsR);
           end
       end
    end
end

%Funcion que obtiene el color de cada punto de la funcion
function evalFunc = colorFuncion(Z, matrizRGB,numpointsR,numpointsTheta,extremoR,pond,extremoTheta,numpointsX1,numpointsY1,intervalos,pintarContour, numContour)
    %Para cada punto, obtenemos su modulo y argumento y buscamos en la matriz de referencia que color le corresponde
    evalFunc = zeros(numpointsX1,numpointsY1,3);
    for i=1:numpointsX1
       for j=1:numpointsY1 
           eval=Z(i,j);
		   
		   %Vemos primero si el valor es Inf o NaN
           if (eval==Inf || real(eval)==Inf || imag(eval)==Inf || real(eval)==-Inf || imag(eval)==-Inf || isnan(eval) || isnan(real(eval)) || isnan(imag(eval))) 
               evalFunc(i,j,:)=[1 1 1];
           else
               %Obtenemos el modulo y argumento
			   r = abs(eval);
			   t = angle(eval);
			   if t<0
				  t = t + 2*pi; 
			   end
			   
			   %Obtenemos la posicion donde se encuentra en la matriz de referencia
			   if r<=pond, fila = round(r*numpointsR/pond);
			   else fila = numpointsR+round((r*numpointsR-pond*numpointsR)/(extremoR-pond));
			   end
			   columna = round(t*numpointsTheta/extremoTheta);
               if fila == 0
				   fila = 1;
               end
               if columna==0
				  columna=1; 
               end
                
               %Si la fila o la columna no son Inf ni NaN, guardamos el color
               if isnan(fila) || isnan(columna) || fila==Inf || columna==Inf
                   evalFunc(i,j,:)=[1 1 1];
               else evalFunc(i,j,:) = matrizRGB(fila, columna,:);
               end
           end
       end
    end
    
    %Giramos la matriz para su correcta visualizacion
    evalFunc(:,:,1) = rot90(evalFunc(:,:,1));
    evalFunc(:,:,2) = rot90(evalFunc(:,:,2));
    evalFunc(:,:,3) = rot90(evalFunc(:,:,3));
    
    %Pintamos la funcion correctamente
    pintarEvalFunc(Z, evalFunc, numpointsX1, numpointsY1, intervalos, pintarContour, numContour);
end

%Funcion que dibuja la matriz de colores de la funcion
function pintarEvalFunc(Z, evalFunc, numpointsX1, numpointsY1, intervalos, pintarContour, numContour)
    image(evalFunc)
    hold on
    
    %Pintamos las curvas de nivel de la parte real e imaginaria
    if pintarContour == true
        Z = rot90(Z);
        c = linspace(-pi,pi,numContour);
        contour(real(Z),c, 'k')
        contour(imag(Z),c, 'r')
    end
    hold off
    
    %Establecemos los ejes de la grafica
    tickX1 = 1:(numpointsX1-1)/4:numpointsX1;
    tickY1 = 1:(numpointsY1-1)/4:numpointsY1;
    labelx1 = linspace(intervalos(1),intervalos(2),5);
    labely1 = linspace(intervalos(3),intervalos(4),5);
    set(gca,'xtick',tickX1,'xticklabel',labelx1,'ytick',tickY1,'yticklab',labely1,'fontname','symbol','fontsize',12,'DataAspectRatio',[1 1 1])
end

%Input de la funcion
function edit1_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end

function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%Input de X0
function edit2_Callback(hObject, eventdata, handles)
end

function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%Input de X1
function edit3_Callback(hObject, eventdata, handles)
end

function edit3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%Input de Y0
function edit4_Callback(hObject, eventdata, handles)
end

function edit4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%Input de Y1
function edit5_Callback(hObject, eventdata, handles)
end

function edit5_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%Slider de Precision
function slider1_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end

function slider1_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

%Slider de Oscuridad
function slider2_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end

function slider2_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

%Checkbox de las curvas de nivel
function checkbox1_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end
