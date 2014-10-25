package com.mobilegridinc.connect.editor.desktop;

import javax.swing.*;
import java.awt.event.*;
import java.io.File;
//import com.mobilegridinc.schema.connect.*;
//import com.mobilegridinc.schema.coredata.*;


/**
 * Created by tony on 7/16/14.
 */
public class DesktopControllerImpl {

    private final DesktopFrame desktopFrame = new DesktopFrame ();
    private final JDialog     dialog        = new JDialog(desktopFrame,true);

    private final ProjectOverviewController overviewController   = new ProjectOverviewController ();

//    private Document modelDocument = null;
//    private Doc wadlDocument  = null;

    public DesktopControllerImpl () {

        desktopFrame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);

        desktopFrame.addWindowListener(new WindowAdapter(){
            @Override
            public void windowClosing(WindowEvent evt) {
                System.exit(0);           // default frame closing behavior
            }
        });

        //
        // Setup the actions for the toolbar menu
        //
        JToolBar toolBar = desktopFrame.getToolBar();
        JButton  button  = null;

        ActionListener newActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                System.out.println("Action [" + actionEvent.getActionCommand( ) + "]!");
            }
        };
        ActionListener openActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                System.out.println("Action [" + actionEvent.getActionCommand( ) + "]!");
            }
        };
        ActionListener closeActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                System.out.println("Action [" + actionEvent.getActionCommand( ) + "]!");
            }
        };
        ActionListener importModelActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {

                JFileChooser chooser = new JFileChooser( );
                chooser.setMultiSelectionEnabled(false);

                // Open the chooser
                int option = chooser.showOpenDialog(desktopFrame);

                if (option == JFileChooser.APPROVE_OPTION) {
                    String path = chooser.getSelectedFile().getPath();

                    System.out.println("Importing Model File " + path);

                    File file = new File(path);

                    if (file.isDirectory()) {

                        File[] directoryListing = file.listFiles();

                        if (directoryListing != null) {
                            if (directoryListing.length == 1) {
                                path = directoryListing[0].getPath();
                            } else {
                                System.out.println("Error model files with multiple versions not supported at this time.");
                            }
                        }
                    }
//                    modelDocument = (new com.mobilegridinc.connect.schema.coredata.Reader()).readURL(path);
//
//                    printModelXMLDocument(modelDocument);
                }
            }
        };
        ActionListener importWADLActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {

                JFileChooser chooser = new JFileChooser( );
                chooser.setMultiSelectionEnabled(false);

                // Open the chooser
                int option = chooser.showOpenDialog(desktopFrame);

                if (option == JFileChooser.APPROVE_OPTION) {
                    System.out.println("Importing WADL File...");

//                    try {
//
//                        JAXBContext jaxbContext = JAXBContext.newInstance(Application.class);
//
//                        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
//
//                        // specify the location and name of xml file to be read
//                        File xmlFile = new File(chooser.getSelectedFile().getPath());
//
//                        Application application = (Application) jaxbUnmarshaller.unmarshal(xmlFile);
//
//                        System.out.println();
//
//                    } catch (JAXBException e) {
//                        // some exception occured
//                        e.printStackTrace();
//                    }
                }
            }
        };

        button = new JButton("New");
        button.addActionListener(newActionListener);
        toolBar.add(button);

        button = new JButton("Open");
        button.addActionListener(openActionListener);
        toolBar.add(button);

        button = new JButton("Close");
        button.addActionListener(closeActionListener);
        toolBar.add(button);

//        toolBar.add(new Spacer());

        button = new JButton("Import Model");
        button.addActionListener(importModelActionListener);
        toolBar.add(button);

        button = new JButton("Import WADL");
        button.addActionListener(importWADLActionListener);
        toolBar.add(button);


        desktopFrame.pack();
    }

    public JFrame getFrame () { return desktopFrame; }

}
