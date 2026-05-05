package com.stegano;

import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;

public class SteganographyUtil {

    private static final String DELIMITER = "$$END$$";

    // ==================== ENCODE ====================
    public static BufferedImage encode(BufferedImage image, String message) throws Exception {
        String fullMessage = message + DELIMITER;
        byte[] msgBytes = fullMessage.getBytes("UTF-8");

        int maxBytes = (image.getWidth() * image.getHeight() * 3) / 8;
        if (msgBytes.length > maxBytes) {
            throw new Exception("Message too large! Max: " + maxBytes + " bytes.");
        }

        // Original image থেকে copy বানাও
        BufferedImage result = new BufferedImage(
                image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);

        // আগে সব pixel copy করো
        for (int y = 0; y < image.getHeight(); y++) {
            for (int x = 0; x < image.getWidth(); x++) {
                result.setRGB(x, y, image.getRGB(x, y));
            }
        }

        // এখন message encode করো
        int msgIndex = 0;
        int bitIndex = 0;

        outer:
        for (int y = 0; y < result.getHeight(); y++) {
            for (int x = 0; x < result.getWidth(); x++) {
                if (msgIndex >= msgBytes.length) break outer;

                int pixel = result.getRGB(x, y);
                int r = (pixel >> 16) & 0xFF;
                int g = (pixel >> 8) & 0xFF;
                int b = pixel & 0xFF;

                // R channel এ bit বসাও
                if (msgIndex < msgBytes.length) {
                    int bit = (msgBytes[msgIndex] >> (7 - bitIndex)) & 1;
                    r = (r & 0xFE) | bit;
                    bitIndex++;
                    if (bitIndex == 8) { bitIndex = 0; msgIndex++; }
                }

                // G channel এ bit বসাও
                if (msgIndex < msgBytes.length) {
                    int bit = (msgBytes[msgIndex] >> (7 - bitIndex)) & 1;
                    g = (g & 0xFE) | bit;
                    bitIndex++;
                    if (bitIndex == 8) { bitIndex = 0; msgIndex++; }
                }

                // B channel এ bit বসাও
                if (msgIndex < msgBytes.length) {
                    int bit = (msgBytes[msgIndex] >> (7 - bitIndex)) & 1;
                    b = (b & 0xFE) | bit;
                    bitIndex++;
                    if (bitIndex == 8) { bitIndex = 0; msgIndex++; }
                }

                // নতুন pixel set করো (alpha = 255)
                result.setRGB(x, y, (0xFF << 24) | (r << 16) | (g << 8) | b);
            }
        }

        return result;
    }

    // ==================== DECODE ====================
    public static String decode(BufferedImage image) throws Exception {
        StringBuilder bits = new StringBuilder();
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();

        for (int y = 0; y < image.getHeight(); y++) {
            for (int x = 0; x < image.getWidth(); x++) {
                int pixel = image.getRGB(x, y);

                int r = (pixel >> 16) & 0xFF;
                int g = (pixel >> 8) & 0xFF;
                int b = pixel & 0xFF;

                bits.append(r & 1);
                bits.append(g & 1);
                bits.append(b & 1);

                while (bits.length() >= 8) {
                    String byteStr = bits.substring(0, 8);
                    bits.delete(0, 8);
                    int byteVal = Integer.parseInt(byteStr, 2);
                    byteStream.write(byteVal);

                    String decoded = byteStream.toString("UTF-8");
                    if (decoded.contains(DELIMITER)) {
                        int idx = decoded.indexOf(DELIMITER);
                        return decoded.substring(0, idx);
                    }
                }
            }
        }

        throw new Exception("No hidden message found in this image!");
    }

    // ==================== TO BYTES ====================
    public static byte[] toBytes(BufferedImage image) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);
        return baos.toByteArray();
    }
}