import { Resend } from 'resend';
import { config } from '../config/index';

let resend: Resend;

const getResend = (): Resend => {
  if (!resend) {
    resend = new Resend(config.resendApiKey);
  }
  return resend;
};

export const sendVerificationCode = async (
  email: string,
  code: string
): Promise<void> => {
  const mail = getResend();

  const { error } = await mail.emails.send({
    from: config.emailFrom,
    to: email,
    subject: 'Kode Verifikasi BreadGo',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 400px; margin: 0 auto;">
        <h2 style="color: #333;">Verifikasi Email BreadGo</h2>
        <p>Terima kasih telah mendaftar! Gunakan kode berikut untuk memverifikasi email kamu:</p>
        <div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 20px; background: #f5f5f5; border-radius: 8px; margin: 20px 0;">
          ${code}
        </div>
        <p>Kode ini berlaku selama <strong>10 menit</strong>.</p>
        <p style="color: #888; font-size: 12px;">Jika kamu tidak mendaftar di BreadGo, abaikan email ini.</p>
      </div>
    `,
    text: `Kode verifikasi BreadGo kamu: ${code}. Kode ini berlaku selama 10 menit. Jika kamu tidak mendaftar di BreadGo, abaikan email ini.`,
  });

  if (error) {
    throw new Error(`Failed to send email: ${error.message}`);
  }
};
