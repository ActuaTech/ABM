/**
* Interface for objects that can be placed in the roadmap
*/
public interface Placeable {
    public void place(Roads roads);
    public PVector getPosition();
    public boolean select(int mouseX, int mouseY);
    public void draw(PGraphics canvas);
}
