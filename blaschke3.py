#Victor del Valle del Apio
#victorvalleapio@gmail.com
#Julio de 2015

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon,Circle

#Clase principal del programa
class Blaschke3 :
    
    #Metodo para inicializar las variables 
    def __init__(self,ax,fig) :
        self.polygon = []
        self.cont = 0
        self.polygon_exist = False
        self.num_points = 20
        self.touched_circle = False
        self.list_circles = []
        self.ax = ax
        self.fig = fig
        self.cid_press = fig.canvas.mpl_connect('button_press_event', self.on_press)
        self.cid_move = fig.canvas.mpl_connect('motion_notify_event', self.on_move)
        self.cid_release = fig.canvas.mpl_connect('button_release_event', self.on_release)

    #Metodo que se activa cuando se pulsa un punto
    def on_press(self, event):
        #Comprobamos si hemos pulsado en un punto antiguo para moverlo
        for circle in self.list_circles:
            contains, attr = circle.contains(event)
            if contains:
                self.touched_circle = circle
                self.exists_touched_circle = True
                self.pressed_event = event
                self.touched_x0, self.touched_y0 = circle.center
                return
                
        #Limpiamos los ejes y pintamos todos los puntos  
        plt.cla()        
        if self.cont==2:
            self.list_circles.remove(self.list_circles[0])
        c = Circle((event.xdata,event.ydata),0.02)
        ax.add_patch(Circle((0,0),1,color='blue', fill = False))
        self.list_circles.append(c)
        for circle in self.list_circles :
            self.ax.add_patch(circle)
        
        #Guardamos el nuevo punto (borrando el primero si ya habia dos)
        new_point = [event.xdata,event.ydata]
        if not(self.polygon_exist) :
            self.polygon.append(new_point)
            self.P = Polygon(self.polygon, closed = False,color = 'red', fill = False)
            self.polygon_exist = True
        else : 
            if self.cont==2:
                self.polygon.remove(self.polygon[0])
            self.polygon.append(new_point)
        self.P.set_xy(self.polygon)
        self.ax.add_patch(self.P)
        self.fig.canvas.draw()
        
        #Si a1 y a2 se encuentran dentro del disco unidad:
        if self.cont<2:
            self.cont=self.cont+1
        if self.cont==2:
            a1 = self.polygon[0]
            a2 = self.polygon[1]
            if np.linalg.norm(a1)<=1 and np.linalg.norm(a2)<=1:
                self.calculate_Blaschke3(a1,a2)

    #Metodo que se activa cuando se mueve un punto
    def on_move(self,event) : 
        
        if self.touched_circle and self.cont==2:
            dx = event.xdata - self.pressed_event.xdata
            dy = event.ydata - self.pressed_event.ydata
            x0, y0 = self.touched_circle.center
            self.touched_circle.center =  self.touched_x0 + dx, self.touched_y0 + dy
            plt.cla()
            ax.add_patch(Circle((0,0),1,color='blue', fill = False))
            for circle in self.list_circles :
                self.ax.add_patch(circle)
            self.polygon = [circle.center for circle in self.list_circles]
            self.P.set_xy(self.polygon)
            self.ax.add_patch(self.P)
            self.fig.canvas.draw()
            
            if self.cont==2:
                a1 = self.polygon[0]
                a2 = self.polygon[1]
                if np.linalg.norm(a1)<=1 and np.linalg.norm(a2)<=1:
                    self.calculate_Blaschke3(a1,a2)
        
    #Metodo que se activa cuando se suelta un punto
    def on_release(self, event) :
        self.touched_circle = False
    
    #Funcion principal
    def calculate_Blaschke3(self, a1, a2):
        a1 = complex(a1[0],a1[1])
        a2 = complex(a2[0],a2[1])
        t = np.linspace(0,2*np.pi,self.num_points)
        #Para cada punto del disco unidad, calculamos sus tres imagenes inversas        
        for interv in t:
            z = np.exp(interv*1j)
            
            #Resolvemos la ecuacion para calcular las tres raices
            a = 1
            b = -(a1+a2+a1.conjugate()*a2.conjugate()*z)
            c = (a1*a2+a1.conjugate()*z+a2.conjugate()*z)
            d = -z   
            solucion = np.roots([a, b, c, d])
            sol1=complex(solucion[0])
            sol2=complex(solucion[1])
            sol3=complex(solucion[2])
            
            #Dibujamos las 3 rectas
            plane=[]
            plane.append([sol1.real,sol1.imag])
            plane.append([sol2.real,sol2.imag])
            plane.append([sol3.real,sol3.imag])
            Pdraw = Polygon(plane, closed = True,color = 'red', fill = False)
            ax.add_patch(Pdraw)
           
#Funcion Main            
if __name__ == "__main__" :
    fig = plt.figure()
    ax = fig.add_subplot(111,aspect = 1)
    ax.set_xlim(-1,1)
    ax.set_ylim(-1,1)
    ax.add_patch(Circle((0,0),1,color='blue', fill = False))
    b3 = Blaschke3(ax,fig) 
    plt.show()
