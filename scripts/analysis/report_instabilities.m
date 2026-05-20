function report = report_instabilities(out)
%REPORT_INSTABILITIES Print time-localized instability metrics from simulation output.
%   report = report_instabilities(out)
%
%   Expected fields in `out`:
%     - A_s: state matrix over time, size [n n N]
%     - B_s: input matrix over time, size [n m N]
%     - K_s: gain matrix over time, size [m n N]
%     - tout: simulation time vector (optional but recommended)

report = struct( ...
    'totalSamples', 0, ...
    'unstableSamples', 0, ...
    'unstablePercent', 0, ...
    'maxRealPart', [], ...
    'unstableIndex', [], ...
    'unstableTimes', []);

requiredFields = {'A_s', 'B_s', 'K_s'};
for i = 1:numel(requiredFields)
    if ~isfield(out, requiredFields{i})
        warning('report_instabilities:missingField', ...
            'Missing out.%s. Instability report skipped.', requiredFields{i});
        return;
    end
end

A_s = out.A_s;
B_s = out.B_s;
K_s = out.K_s;

nA = size(A_s, 3);
nB = size(B_s, 3);
nK = size(K_s, 3);
N = min([nA, nB, nK]);

if N == 0
    warning('report_instabilities:emptyData', 'Empty A_s/B_s/K_s data.');
    return;
end

maxReal = zeros(N, 1);
unstable = false(N, 1);

for k = 1:N
    Ak = A_s(:, :, k);
    Bk = B_s(:, :, k);
    Kk = K_s(:, :, k);
    poles = eig(Ak - Bk * Kk);
    maxReal(k) = max(real(poles));
    unstable(k) = maxReal(k) > 0;
end

report.totalSamples = N;
report.unstableSamples = nnz(unstable);
report.unstablePercent = 100 * report.unstableSamples / N;
report.maxRealPart = maxReal;
report.unstableIndex = find(unstable);

if isfield(out, 'tout') && numel(out.tout) >= N
    t = out.tout(:);
    report.unstableTimes = t(report.unstableIndex);
end

if report.unstableSamples == 0
    fprintf('Stability report: no unstable samples detected (%d total).\n', N);
else
    fprintf('Stability report: unstable samples = %d / %d (%.6f%%).\n', ...
        report.unstableSamples, N, report.unstablePercent);

    firstN = min(10, report.unstableSamples);
    idxPreview = report.unstableIndex(1:firstN);

    if ~isempty(report.unstableTimes)
        tPreview = report.unstableTimes(1:firstN);
        fprintf('First %d unstable times (s):\n', firstN);
        disp(tPreview');
    else
        fprintf('First %d unstable indices:\n', firstN);
        disp(idxPreview');
    end

    fprintf('Max(real(pole)) over run: %.6g\n', max(maxReal));
end
end
