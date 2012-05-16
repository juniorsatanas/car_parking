class Board {
  
  // The board is redrawn every INTERVAL ms.
  static final int INTERVAL = 8; 
  
  static final int LINE_WIDTH = 1;
  static final String LINE_COLOR = '#000000'; // black
  static final int SSS = 8; // selection square size
  
  static final int ROWS_COUNT = 6;
  static final int COLUMNS_COUNT = 6;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  int width;
  int height;
  int cellWidth;
  int cellHeight;
  
  Parking parking;
  
  Board(this.canvas, this.parking) {
    context = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    cellWidth = width ~/ COLUMNS_COUNT;
    cellHeight = height ~/ ROWS_COUNT;
    border();
 
    // Canvas event.
    document.query('#canvas').on.mouseDown.add(onMouseDown);
    // Redraw every INTERVAL ms.
    document.window.setInterval(redraw, INTERVAL);
  }
  
  void redraw() {
    clear(); 
    displayCars();
  }
  
  void clear() {
    context.clearRect(0, 0, width, height);
    border();
  } 
  
  void border() {
    context.beginPath();
    context.rect(0, 0, width, height);
    context.lineWidth = LINE_WIDTH;
    context.strokeStyle = LINE_COLOR;
    context.stroke();
    context.closePath();
  }
  
  void displayCars() {
    for (Car car in parking.cars) {
      displayCar(car);
    }
  }
  
  void displayCar(Car car) {
    context.beginPath();
    int row = car.currentRow;
    int column = car.currentColumn;
    int x = column * cellWidth;
    int y = row * cellHeight;
    int carLength = car.carBrand.length;
    int carWidth = cellWidth;
    int carHeight = cellHeight;
    if (car.orientation == 'horizontal') {
      carWidth = cellWidth * carLength;  
    } else {
      carHeight = cellHeight * carLength;
    }
    context.lineWidth = LINE_WIDTH;
    context.strokeStyle = LINE_COLOR;
    context.fillStyle = car.carBrand.color;
    //context.rect(x, y , carWidth, carHeight);
    context.fillRect(x, y , carWidth, carHeight);  
    if (car.selected) {
      context.rect(x, y, SSS, SSS);
      context.rect(x + carWidth - SSS, y, SSS, SSS);
      context.rect(x + carWidth - SSS, y + carHeight - SSS, SSS, SSS);
      context.rect(x, y + carHeight - SSS, SSS, SSS);
    } 
    context.stroke();
    context.closePath();
  }
  
  Car getCarInCell(int row, int column) {
    for (Car car in parking.cars) {
      if (car.inCell(row, column)) {
        return car;
      } 
    }
    return null;
  }
  
  Car getSelectedCarAfterOrBeforeCell(int row, int column) {
    for (Car car in parking.cars) {
      if (car.selected && car.afterOrBeforeCell(row, column)) {
        return car;
      } 
    }
    return null;
  }
  
  void onMouseDown(MouseEvent e) {
    int row = e.offsetY ~/ cellHeight;
    int column = e.offsetX ~/ cellWidth;
    Car car = getCarInCell(row, column);
    if (car != null) {  
      parking.cars.deselect();
      car.selected = true;
    } else {
      car = getSelectedCarAfterOrBeforeCell(row, column);
      if (car != null) { 
        car.moveToOrTowardCell(row, column);
        if (car.carBrand.code == 'X' && car.currentColumn == COLUMNS_COUNT - car.carBrand.length) {
          car.currentColumn = COLUMNS_COUNT; // the car exits the parking
        }
      } 
    }
  }
  
}