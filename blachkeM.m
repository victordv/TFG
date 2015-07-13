%Victor del Valle del Apio
%victorvalleapio@gmail.com
%Julio de 2015

%Aplicacion de los productos de Blaschke de grado m

function varargout = guiBlaschkeM(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @guiBlaschkeM_OpeningFcn, ...
                       'gui_OutputFcn',  @guiBlaschkeM_OutputFcn, ...
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

function guiBlaschkeM_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    pushbutton1_Callback(hObject, eventdata, handles);
end

function varargout = guiBlaschkeM_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

%Funcion principal
function pushbutton1_Callback(hObject, eventdata, handles)
    %Limpiamos los ejes
    cla
    hold on
    axis equal
    syms z;
    
    %Obtenemos los valores introducidos de a
    a = get(handles.edit1, 'String');
    vectorA = str2num(a);
    
    %Si todos los puntos se encuentran dentro del disco unidad:
    dentroDisco = true;
    for ind=1:length(vectorA)
        if(norm(vectorA(ind))>=1)
            dentroDisco = false;
        end
    end
    
    if (dentroDisco==true) 
        set(handles.text3, 'String', ['Producto de Blaschke de grado ' num2str(length(vectorA)+1)])
     
        %Dibujamos los a_i
        for ind = 1:length(vectorA)
           plot(real(vectorA(ind)), imag(vectorA(ind)), '-*b') 
        end

        %Para cada punto del disco unidad, calculamos sus m imagenes inversas
        for lambda2=0:0.5:2*pi
            lambda = exp(1i*lambda2);
            
            %Calculamos el producto de Blaschke
            fun1 = z;
            fun2 = -lambda;
            for ind=1:length(vectorA)
                fun1 = fun1*(z-vectorA(ind));
                fun2 = fun2*(1-conj(vectorA(ind))*z);
            end
            fun = fun1+fun2;
            
            %Obtenemos los coeficientes y sus raices
            coeficientes = coeffs(fun,z);
            sol = sym2poly(coeficientes);
            sol = fliplr(sol);
            r = roots(sol);

            %Ordenamos los puntos en funcion del argumento
            n = length(r);
            for i=1:n 
                for j=1:n-i 
                    if angle(r(j))>angle(r(j+1)) 
                        aux=r(j); 
                        r(j)=r(j+1); 
                        r(j+1)=aux; 
                    end 
                end 
            end 

            %Dibujamos las m rectas
            for ind = 1:length(r)
                m(ind, 1) = real(r(ind));
                m(ind, 2) = imag(r(ind));
            end

            for ind = 1:length(r)-1
                plot([m(ind,1) m(ind+1,1)],[m(ind,2) m(ind+1,2)],'r')
            end
            plot([m(length(r),1) m(1,1)],[m(length(r),2) m(1,2)],'r')
        end

        %Dibujamos el disco unidad
        theta_grid = linspace(0,2*pi);
        circ_x = cos(theta_grid);
        circ_y = sin(theta_grid);
        plot(circ_x, circ_y,'b')

	%Si alguno de los puntos no estaba en el disco unidad:
    else
        set(handles.text3, 'String', 'No todos los puntos están dentro del disco unidad')
    end

    hold off
end

%Input de a1
function edit1_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end

function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
