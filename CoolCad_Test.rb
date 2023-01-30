  include RBA
  app = Application.instance
  
  #Gesture handler for the icon in the editor
  class MenuHandler < RBA::Action
    def initialize( t, k, i, &action ) 
      self.title = t
      self.shortcut = k
      self.icon = i
      @action = action
    end
    def triggered 
      @action.call( self ) 
    end
  private
    @action
  end

  
  
  $menu_handler = MenuHandler.new( "CoolCad Test", "Shift+F7", "icon.png" ) {
  #Popup window for the user to select the value of n
    n = RBA::InputDialog.get_int("Input", "Input an integer", 1).to_i
    
    ly = RBA::CellView::active.layout
    lv = RBA::Application.instance.main_window.current_view
    li = ly.layer(1, 0)
    xMax = yMax = -(2**(0.size * 8 -2))
    xMin = yMin = (2**(0.size * 8 -2) -1)
    
    cell = ly.top_cell
    origin = []
    
    lv.each_object_selected { |obj|
      #Traverse through each point, calculating local 
      #max and min x/y coordinates
      shape = obj.shape
      if shape.is_polygon?
        shape.polygon.each_point_hull { |pt|
        if (pt.x > xMax)
          xMax = pt.x
        elsif (pt.x < xMin)
          xMin = pt.x
        end
        
        if (pt.y > yMax)
          yMax = pt.y
        elsif (pt.y < yMin)
          yMin = pt.y
        end
        
          origin.push(pt)
        }
      end
    }   
  
  #These coordinates will help dictate what direction the 
  #points must move in when drawing the new squares
  xAxis = xMax - (Math.sqrt((xMax - xMin) ** 2) / 2)
  yAxis = yMax - (Math.sqrt((yMax - yMin) ** 2) / 2)

  n.times do |i|
  modified = []
    while (origin.length > 0) do
      coord = origin.shift
      if (coord.x < xAxis)
          if (coord.y < yAxis)
              #Bottom-left quadrant
              coord.x = coord.x + (-1 * (4000 + (i * 2000)))
              coord.y = coord.y + (-1 * (4000 + (i * 2000)))
          else
              #Top-left quadrant
              coord.x = coord.x + (-1 * (4000 + (i * 2000)))
              coord.y = coord.y + (1 * (4000 + (i * 2000)))
          end
      else
          if (coord.y < yAxis)
              #Bottom-right quadrant
              coord.x = coord.x + (1 * (4000 + (i * 2000)))
              coord.y = coord.y + (-1 * (4000 + (i * 2000)))
          else
              #Top-right quadrant
              coord.x = coord.x + (1 * (4000 + (i * 2000)))
              coord.y = coord.y + (1 * (4000 + (i * 2000)))
          end
      end
      modified.push(coord)
    end
  
    #All drawing on the layout happens here
    path = RBA::Polygon::new(modified,true)
    ly.top_cell.shapes(li).insert(path)
    while (modified.length > 0) do
        origin.push(modified.shift)
    end
  end

  }

  menu = app.main_window.menu
  menu.insert_item("@toolbar.end", "rba_test", $menu_handler)
  menu.insert_item("tools_menu.end", "rba_test", $menu_handler)

  app.exec