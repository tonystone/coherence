package com.mobilegridinc.connect.editor.desktop;

/**
 * Created by tony on 7/16/14.
 */
import javax.swing.*;
import java.awt.*;

/**
 * Created by tony on 7/16/14.
 */
public class DesktopFrame extends JFrame {

    private JToolBar   toolBar;
    private JSplitPane verticalSplitPane;
    private JSplitPane horizontalSplitPane;

    public JToolBar  getToolBar()          { return toolBar; }
    public Component getLeftComponent ()   { return verticalSplitPane.getLeftComponent(); }
    public Component getRightComponent ()  { return verticalSplitPane.getRightComponent(); }
    public Component getBottomComponent () { return horizontalSplitPane.getRightComponent(); }

    public DesktopFrame () {
        this.setName("Connect Editor");

        JPanel panel1 = new JPanel();
        panel1.setLayout(new BorderLayout(0, 0));
        panel1.setFocusTraversalPolicyProvider(false);
//        panel1.setMinimumSize(new Dimension(100, 50));
        panel1.setPreferredSize(new Dimension(1024, 800));

        this.setContentPane(panel1);

        //
        // Add a toolbar to the top
        //
        toolBar = new JToolBar();
        panel1.add(toolBar, BorderLayout.NORTH);

        //
        // These are the main split panels
        //
        verticalSplitPane = new JSplitPane();
//        verticalSplitPane.setContinuousLayout(true);
//        verticalSplitPane.setFocusTraversalPolicyProvider(false);
        verticalSplitPane.setLastDividerLocation(250);
//        verticalSplitPane.setMinimumSize(new Dimension(-1, -1));
        verticalSplitPane.setOrientation(0);
//        verticalSplitPane.setPreferredSize(new Dimension(800, 600));
        panel1.add(verticalSplitPane, BorderLayout.CENTER);
        horizontalSplitPane = new JSplitPane();
//        horizontalSplitPane.setContinuousLayout(true);
        horizontalSplitPane.setPreferredSize(new Dimension(800, 650));
//        horizontalSplitPane.setResizeWeight(0.75);
        verticalSplitPane.setLeftComponent(horizontalSplitPane);
    }


}