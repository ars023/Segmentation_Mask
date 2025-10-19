# Segmentation_Mask
Creates a segmentation mask for an object in a grayscale image. Uses ratios between vector values and Laplace Smoothened PMF's and prior probabilities to determine whether every 8x8 block is a cheetah or not and then uses a sliding window to map the center to the decided result. (WIP)

What it currently looks like:

<img width="726" height="722" alt="mask" src="https://github.com/user-attachments/assets/e3127391-bff6-44f3-a7d1-ba494828baab" />

Image used:

<img width="724" height="684" alt="original" src="https://github.com/user-attachments/assets/99825723-382c-47c0-846e-925f81898fdb" />


