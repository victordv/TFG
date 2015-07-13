#Victor del Valle del Apio
#victorvalleapio@gmail.com
#Julio de 2015

import numpy as np
import sympy as sp
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon,Circle

#Clase principal del programa
class BlaschkeM : 
    
    #Metodo para inicializar las variables
    def __init__(self,ax,fig) :
        self.polygon = []
        self.dentroDisco = True
        self.num_points = 12
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
        c = Circle((event.xdata,event.ydata),0.02)
        ax.add_patch(Circle((0,0),1,color='blue', fill = False))
        self.list_circles.append(c)
        for circle in self.list_circles :
            self.ax.add_patch(circle)
        
        #Guardamos el nuevo punto 
        new_point = [event.xdata,event.ydata]
        self.polygon.append(new_point)
        self.fig.canvas.draw()
        
        #Si todos los puntos se encuentran dentro del disco unidad:
        self.dentroDisco=True
        for punto in self.polygon:
            if np.linalg.norm(punto)>=1:
                self.dentroDisco=False
        if self.dentroDisco==True:
                self.calculate_BlaschkeM()

    #Metodo que se activa cuando se mueve un punto
    def on_move(self,event) : 
        if self.touched_circle:
            dx = event.xdata - self.pressed_event.xdata
            dy = event.ydata - self.pressed_event.ydata
            x0, y0 = self.touched_circle.center
            self.touched_circle.center =  self.touched_x0 + dx, self.touched_y0 + dy
            
            #Limpiamos los ejes y pintamos todos los puntos 
            plt.cla()
            ax.add_patch(Circle((0,0),1,color='blue', fill = False))
            for circle in self.list_circles :
                self.ax.add_patch(circle)
            self.polygon = [circle.center for circle in self.list_circles]
            self.fig.canvas.draw()
            
            #Si todos los puntos se encuentran dentro del disco unidad:
            self.dentroDisco=True
            for punto in self.polygon:
                if np.linalg.norm(punto)>=1:
                    self.dentroDisco=False
            if self.dentroDisco==True:
                    self.calculate_BlaschkeM()
        
    #Metodo que se activa cuando se suelta un punto
    def on_release(self, event) :
        self.touched_circle = False
    
    #Funcion principal
    def calculate_BlaschkeM(self):
        t = np.linspace(0,2*np.pi,self.num_points)
        z = sp.Symbol('z')
        
        #Para cada punto del disco unidad, calculamos sus m imagenes inversas
        for interv in t:
            lambda2 = np.exp(interv*1j)
            
            #Convertimos los puntos introducidos en numeros complejos
            polinomio = []
            for ind in range(len(self.polygon)):
                polinomio.append(complex(self.polygon[ind][0],self.polygon[ind][1]))
            
            #Calculamos el producto de Blaschke
            fun1 = z;
            fun2 = -lambda2;
            for ind in range(len(polinomio)):
                fun1 = fun1*(z-polinomio[ind]);
                fun2 = fun2*(1-polinomio[ind].conjugate()*z);
            fun = fun1+fun2;    
            
            #Obtenemos los coeficientes y sus raices
            poly = sp.Poly(fun, z)
            coeficientes = poly.coeffs()
            for ind in range(len(coeficientes)):
                coeficientes[ind] = complex(coeficientes[ind])
            r = np.roots(coeficientes)
            
            #Ordenamos los puntos en funcion del argumento
            r = sorted(r,key=self.angle)
            
            #Dibujamos las m rectas
            plane=[]
            for ind in range(len(r)):
                plane.append([r[ind].real, r[ind].imag])             
            Pdraw = Polygon(plane, closed = True,color = 'red', fill = False)
            ax.add_patch(Pdraw)
            
    #Funcion que calcula el argumento de los puntos
    def angle(self,asd):
        return np.angle(asd)

#Funcion Main
if __name__ == "__main__" :
    fig = plt.figure()
    ax = fig.add_subplot(111,aspect = 1)
    ax.set_xlim(-1,1)
    ax.set_ylim(-1,1)
    ax.add_patch(Circle((0,0),1,color='blue', fill = False))
    bM = BlaschkeM(ax,fig) 
    plt.show()
