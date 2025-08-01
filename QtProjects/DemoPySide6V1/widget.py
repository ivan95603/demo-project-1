import sys
import random
from PySide6 import QtCore, QtWidgets, QtGui, QtWidgets
from PySide6.QtCore import Qt
from PySide6.QtUiTools import QUiLoader
import requests
import configuration


slider_value = 0

class Widget(QtWidgets.QWidget):
                def __init__(self, parent=None):
                                super().__init__()
                                # self.setWindowState(Qt.WindowMaximized)

                                self.button = QtWidgets.QPushButton("Click me!")
                                self.text = QtWidgets.QLabel("Hello World",
                                                             alignment=QtCore.Qt.AlignCenter)


                                self.slider = QtWidgets.QSlider(Qt.Orientation.Horizontal, self)

                                self.slider.setMinimum(0)
                                self.slider.setMaximum(4095)

                                self.slider.setSingleStep(100)

                                self.slider.valueChanged.connect(self.value_changed)
                                self.slider.sliderMoved.connect(self.slider_position)
                                self.slider.sliderPressed.connect(self.slider_pressed)
                                self.slider.sliderReleased.connect(self.slider_released)


                                self.layout = QtWidgets.QVBoxLayout(self)
                                self.layout.addWidget(self.text)
                                self.layout.addWidget(self.slider)
                                # self.layout.addWidget(self.button)

                                self.button.clicked.connect(self.button_clicked)

                @QtCore.Slot()
                def button_clicked(self):
                                pass

                def value_changed(self, value):
                                global slider_value
                                slider_value = value
                                print(value)


                def slider_position(self, position):
                                print("position", position)

                def slider_pressed(self):
                                print("Pressed!")

                def slider_released(self):

                                myobj = {'slider_value': str(slider_value)}

                                x = requests.post(configuration.SERVER_ADDRESS+"slider_data", json = myobj)


                                try:
                                                                x = requests.post(configuration.SERVER_ADDRESS+"slider_data", json = myobj)

                                                                print(x.text)
                                                                if( x.json()["sucess"]==True):
                                                                                                print("receivedVAL:" + x.json()["value"])
                                                                                                self.text.setText("Value that was written and verified in the database: " + str(x.json()["value"]))
                                except:
                                                                print("Server currently unavailable or some other issue")
                                print("Released")

if __name__ == "__main__":
                # loader = QUiLoader()
                # app = QtWidgets.QApplication(sys.argv)
                # window = loader.load("form.ui", None)
                # window.setWindowFlag(Qt.FramelessWindowHint)
                # window.setWindowState(Qt.WindowMaximized)
                # window.show()

                app = QtWidgets.QApplication([])
                window = Widget()
                window.setWindowFlag(Qt.FramelessWindowHint)

                window.text.setText("Server value will be shown here in the future.")
                window.show()
                sys.exit(app.exec())
