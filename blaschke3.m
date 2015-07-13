%Victor del Valle del Apio
%victorvalleapio@gmail.com
%Julio de 2015

%Aplicacion de los productos de Blaschke de grado tres

function varargout = guiBlaschke3(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @guiBlaschke3_OpeningFcn, ...
                       'gui_OutputFcn',  @guiBlaschke3_OutputFcn, ...
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

function guiBlaschke3_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    pushbutton1_Callback(hObject, eventdata, handles);
end

function varargout = guiBlaschke3_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

%Funcion principal
function pushbutton1_Callback(hObject, eventdata, handles)
    %Limpiamos los ejes
    cla
    hold on
    axis equal
    
    %Obtenemos los valores de a1 y a2 introducidos
    a1 = str2double(get(handles.edit1, 'String'));
    a2 = str2double(get(handles.edit2, 'String'));
    
    %Si a1 y a2 se encuentran dentro del disco unidad:
    if (norm(a1)<1 && norm(a2)<1)  
        set(handles.text3, 'String', ['Producto de Blaschke donde a1 = ' num2str(a1) ' y a2 = ' num2str(a2)])
        
        %Dibujamos a1 y a2
        plot(real(a1), imag(a1), '-*b')
        plot(real(a2), imag(a2), '-*b')
        
        %Para cada punto del disco unidad, calculamos sus tres imagenes inversas
        for lambda=0:0.5:2*pi
            z = exp(1i*lambda);
            
            %Resolvemos la ecuacion para calcular las tres raices
            p = [1 -(a1+a2+conj(a1)*conj(a2)*z) (a1*a2+conj(a1)*z+conj(a2)*z) -z];
            r = roots(p);
            
            %Con las tres raices, dibujamos el triangulo que forman
            for ind = 1:length(r)
                m(ind, 1) = real(r(ind));
                m(ind, 2) = imag(r(ind));
            end
            plot([m(1,1) m(2,1)],[m(1,2) m(2,2)],'r')
            plot([m(1,1) m(3,1)],[m(1,2) m(3,2)],'r')
            plot([m(2,1) m(3,1)],[m(2,2) m(3,2)],'r')
        end

        %Dibujamos el disco unidad
        theta_grid = linspace(0,2*pi);
        circ_x = cos(theta_grid);
        circ_y = sin(theta_grid);
        plot(circ_x, circ_y,'b')

        %Si alguno de los puntos no estaba en el disco unidad:
        elseif(norm(a1)>=1 && norm(a2)<1)
            set(handles.text3, 'String', ['El punto a1 = ' num2str(a1) ' no está dentro del disco unidad'])
        elseif(norm(a1)<1 && norm(a2)>=1)
            set(handles.text3, 'String', ['El punto a2 = ' num2str(a2) ' no está dentro del disco unidad'])
        else
            set(handles.text3, 'String', ['Los puntos a1 = ' num2str(a1) ' y a2 = ' num2str(a2) ' no están dentro del disco unidad'])
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

%Input de a2
function edit2_Callback(hObject, eventdata, handles)
    pushbutton1_Callback(hObject, eventdata, handles)
end

function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
